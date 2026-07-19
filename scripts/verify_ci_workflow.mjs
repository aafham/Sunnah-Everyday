import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

import { parseDocument } from 'yaml';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
export const ciWorkflowPath = resolve(
  scriptDirectory,
  '..',
  '.github',
  'workflows',
  'quality.yml',
);

const pinnedActions = Object.freeze({
  checkout: 'actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5',
  setupNode: 'actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020',
  flutter:
    'subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2',
});

const requiredCommands = Object.freeze([
  'npm ci --ignore-scripts',
  'npm run test:ci-workflow',
  'npm run test:mobile-security',
  'npm run test:quality-audit',
  'npm run test:flutter-runner',
  'npm run test:content-contract',
  'npm run test:content-validation',
  'node scripts/verify_supabase_baseline.mjs',
  'dart format --set-exit-if-changed .',
  'npm run check:flutter',
  'dart analyze',
  'dart test',
  'flutter build apk --debug',
  'flutter build web --release',
]);

const prohibitedPatterns = Object.freeze([
  /pull_request_target/i,
  /\bsecrets?\b/i,
  /github\.token/i,
  /flutter\s+build\s+appbundle/i,
  /bundleRelease/i,
  /fastlane/i,
  /google\s+play/i,
  /play[-_ ]?(console|developer|store)/i,
  /upload-artifact/i,
  /gh\s+release/i,
  /create-release/i,
]);

function addFinding(findings, code, detail) {
  findings.push({ code, detail });
}

function workflowSteps(workflow) {
  if (workflow?.jobs == null || typeof workflow.jobs !== 'object') {
    return [];
  }

  return Object.values(workflow.jobs).flatMap((job) =>
    Array.isArray(job?.steps) ? job.steps : [],
  );
}

function workflowRunLines(workflow) {
  return workflowSteps(workflow)
    .map((step) => (typeof step?.run === 'string' ? step.run : ''))
    .flatMap((run) => run.split('\n'))
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith('#'));
}

function validateJobShape(workflow, findings) {
  const jobs = workflow?.jobs;
  const requiredJobNames = ['contracts', 'flutter-quality', 'build-smoke'];
  if (jobs == null || typeof jobs !== 'object') {
    addFinding(findings, 'CI_JOBS_MISSING', 'Workflow must define its jobs.');
    return;
  }
  const jobNames = Object.keys(jobs);
  if (
    jobNames.length !== requiredJobNames.length ||
    jobNames.some((jobName) => !requiredJobNames.includes(jobName))
  ) {
    addFinding(
      findings,
      'CI_JOB_ALLOWLIST',
      'Workflow must define only the reviewed quality jobs.',
    );
  }

  for (const jobName of requiredJobNames) {
    const job = jobs[jobName];
    if (job == null) {
      addFinding(findings, 'CI_JOB_MISSING', `Missing ${jobName} job.`);
      continue;
    }
    if (typeof job !== 'object' || Array.isArray(job)) {
      addFinding(
        findings,
        'CI_JOB_SHAPE',
        `${jobName} must be a mapping.`,
      );
      continue;
    }
    if (Object.hasOwn(job, 'permissions')) {
      addFinding(
        findings,
        'CI_JOB_PERMISSIONS',
        `${jobName} must not override the read-only workflow permissions.`,
      );
    }
    if (job['runs-on'] !== 'ubuntu-24.04') {
      addFinding(
        findings,
        'CI_RUNNER',
        `${jobName} must run on ubuntu-24.04.`,
      );
    }
    if (job['timeout-minutes'] !== 20) {
      addFinding(
        findings,
        'CI_TIMEOUT',
        `${jobName} must have a 20-minute timeout.`,
      );
    }
  }

  const buildSmokeNeeds = jobs['build-smoke']?.needs;
  const normalisedNeeds = Array.isArray(buildSmokeNeeds)
    ? buildSmokeNeeds
    : [buildSmokeNeeds];
  if (
    !normalisedNeeds.includes('contracts') ||
    !normalisedNeeds.includes('flutter-quality')
  ) {
    addFinding(
      findings,
      'CI_BUILD_DEPENDENCIES',
      'build-smoke must wait for contracts and flutter-quality.',
    );
  }
}

function validateActionSafety(workflow, findings) {
  const steps = workflowSteps(workflow);
  const usedActions = [];

  for (const step of steps) {
    if (typeof step?.uses !== 'string') {
      continue;
    }
    usedActions.push({ action: step.uses, step });
    if (!/^[\w-]+\/[\w.-]+@[a-f0-9]{40}$/.test(step.uses)) {
      addFinding(
        findings,
        'CI_ACTION_PIN',
        `Action ${step.uses} must use a full commit SHA.`,
      );
    }
  }

  const allowedActions = new Set(Object.values(pinnedActions));
  for (const { action } of usedActions) {
    if (!allowedActions.has(action)) {
      addFinding(
        findings,
        'CI_ACTION_ALLOWLIST',
        `Action ${action} is not in the reviewed allowlist.`,
      );
    }
  }

  const checkoutSteps = usedActions.filter(
    ({ action }) => action === pinnedActions.checkout,
  );
  if (checkoutSteps.length !== 3) {
    addFinding(
      findings,
      'CI_CHECKOUT_COUNT',
      'Each job must use the reviewed checkout action.',
    );
  }
  for (const { step } of checkoutSteps) {
    if (step.with?.['persist-credentials'] !== false) {
      addFinding(
        findings,
        'CI_CHECKOUT_CREDENTIALS',
        'Checkout must disable persisted credentials.',
      );
    }
  }

  const flutterSteps = usedActions.filter(
    ({ action }) => action === pinnedActions.flutter,
  );
  if (flutterSteps.length !== 2) {
    addFinding(
      findings,
      'CI_FLUTTER_ACTION_COUNT',
      'Flutter setup must be explicit in both Flutter jobs.',
    );
  }
  for (const { step } of flutterSteps) {
    if (step.with?.['flutter-version'] !== '3.44.6') {
      addFinding(
        findings,
        'CI_FLUTTER_VERSION',
        'Flutter setup must pin version 3.44.6.',
      );
    }
    if (step.with?.cache !== false) {
      addFinding(
        findings,
        'CI_FLUTTER_CACHE',
        'Flutter action caching must remain disabled.',
      );
    }
  }
}

/// Validates the parsed GitHub Actions workflow against this repository's
/// read-only quality policy. Findings are safe policy codes and descriptions.
export function validateCiWorkflowText(source) {
  const findings = [];
  const document = parseDocument(source, { uniqueKeys: true });
  for (const error of document.errors) {
    addFinding(findings, 'CI_YAML_PARSE', error.message);
  }
  if (findings.length > 0) {
    return { valid: false, findings };
  }

  const workflow = document.toJS();
  const triggers = workflow?.on;
  const triggerNames =
    triggers != null && typeof triggers === 'object'
      ? Object.keys(triggers)
      : [];
  const requiredTriggers = ['push', 'pull_request', 'workflow_dispatch'];
  if (
    triggerNames.length !== requiredTriggers.length ||
    requiredTriggers.some((trigger) => !triggerNames.includes(trigger))
  ) {
    addFinding(
      findings,
      'CI_TRIGGERS',
      'Workflow must use only push, pull_request and workflow_dispatch.',
    );
  }

  const permissions = workflow?.permissions;
  if (
    permissions?.contents !== 'read' ||
    Object.keys(permissions ?? {}).length !== 1
  ) {
    addFinding(
      findings,
      'CI_PERMISSIONS',
      'Workflow permissions must be contents: read only.',
    );
  }

  const concurrency = workflow?.concurrency;
  if (
    concurrency?.group !== 'quality-${{ github.workflow }}-${{ github.ref }}' ||
    concurrency['cancel-in-progress'] !== true
  ) {
    addFinding(
      findings,
      'CI_CONCURRENCY',
      'Workflow must use the reviewed per-ref cancellation group.',
    );
  }

  validateJobShape(workflow, findings);
  validateActionSafety(workflow, findings);

  const runLines = new Set(workflowRunLines(workflow));
  for (const command of requiredCommands) {
    if (!runLines.has(command)) {
      addFinding(
        findings,
        'CI_PARITY_COMMAND',
        `Missing required local-parity command: ${command}.`,
      );
    }
  }
  const structuredWorkflow = JSON.stringify(workflow);
  for (const pattern of prohibitedPatterns) {
    if (pattern.test(structuredWorkflow)) {
      addFinding(
        findings,
        'CI_PROHIBITED_OPERATION',
        `Workflow contains prohibited pattern ${pattern}.`,
      );
    }
  }

  return { valid: findings.length === 0, findings };
}

export function verifyCiWorkflow({ workflowFile = ciWorkflowPath } = {}) {
  const result = validateCiWorkflowText(readFileSync(workflowFile, 'utf8'));
  if (!result.valid) {
    const summary = result.findings
      .map(({ code, detail }) => `${code}: ${detail}`)
      .join('\n');
    throw new Error(`CI workflow verification failed.\n${summary}`);
  }
  return result;
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isDirectExecution) {
  verifyCiWorkflow();
  process.stdout.write('CI workflow policy verification passed.\n');
}
