import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

import {
  ciWorkflowPath,
  validateCiWorkflowText,
  verifyCiWorkflow,
} from './verify_ci_workflow.mjs';

const workflowSource = readFileSync(ciWorkflowPath, 'utf8');

test('quality workflow satisfies the read-only CI policy', () => {
  assert.deepEqual(verifyCiWorkflow(), { valid: true, findings: [] });
});

test('workflow verifier rejects unpinned third-party actions', () => {
  const result = validateCiWorkflowText(
    workflowSource.replace(
      'actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5',
      'actions/checkout@v4',
    ),
  );

  assert.equal(result.valid, false);
  assert.ok(result.findings.some(({ code }) => code === 'CI_ACTION_PIN'));
});

test('workflow verifier rejects privileged pull request events', () => {
  const result = validateCiWorkflowText(
    workflowSource.replace('pull_request:', 'pull_request_target:'),
  );

  assert.equal(result.valid, false);
  assert.ok(result.findings.some(({ code }) => code === 'CI_TRIGGERS'));
  assert.ok(
    result.findings.some(({ code }) => code === 'CI_PROHIBITED_OPERATION'),
  );
});

test('workflow verifier rejects release bundle operations', () => {
  const result = validateCiWorkflowText(
    workflowSource.replace(
      'flutter build apk --debug',
      'flutter build appbundle --release',
    ),
  );

  assert.equal(result.valid, false);
  assert.ok(
    result.findings.some(({ code }) => code === 'CI_PROHIBITED_OPERATION'),
  );
});

test('workflow verifier rejects malformed YAML and secret references', () => {
  const malformed = validateCiWorkflowText('jobs: [');
  const secretReference = validateCiWorkflowText(
    workflowSource.replace(
      'flutter build apk --debug',
      'echo ${{ secrets.PLAY_TOKEN }}',
    ),
  );

  assert.equal(malformed.valid, false);
  assert.ok(malformed.findings.some(({ code }) => code === 'CI_YAML_PARSE'));
  assert.equal(secretReference.valid, false);
  assert.ok(
    secretReference.findings.some(
      ({ code }) => code === 'CI_PROHIBITED_OPERATION',
    ),
  );
});

test('workflow verifier rejects job permission overrides and extra jobs', () => {
  const permissionOverride = validateCiWorkflowText(
    workflowSource.replace(
      '  contracts:\n    name:',
      '  contracts:\n    permissions:\n      contents: write\n    name:',
    ),
  );
  const extraJob = validateCiWorkflowText(
    `${workflowSource}\n  unreviewed:\n    runs-on: ubuntu-24.04\n    steps: []\n`,
  );

  assert.equal(permissionOverride.valid, false);
  assert.ok(
    permissionOverride.findings.some(
      ({ code }) => code === 'CI_JOB_PERMISSIONS',
    ),
  );
  assert.equal(extraJob.valid, false);
  assert.ok(extraJob.findings.some(({ code }) => code === 'CI_JOB_ALLOWLIST'));
});

test('workflow verifier requires executable command lines', () => {
  const result = validateCiWorkflowText(
    workflowSource.replace(
      'run: npm run check:flutter',
      'run: echo npm run check:flutter',
    ),
  );

  assert.equal(result.valid, false);
  assert.ok(result.findings.some(({ code }) => code === 'CI_PARITY_COMMAND'));
});

test('workflow verifier requires the mobile security policy command', () => {
  const result = validateCiWorkflowText(
    workflowSource.replace(
      'run: npm run test:mobile-security',
      'run: echo mobile security policy omitted',
    ),
  );

  assert.equal(result.valid, false);
  assert.ok(result.findings.some(({ code }) => code === 'CI_PARITY_COMMAND'));
});
