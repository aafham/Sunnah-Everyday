import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, '..');

/**
 * Flutter projects that form the baseline unit and widget test suite.
 *
 * Keep this list explicit: the repository root is not a Flutter project, so
 * `flutter test` from the root would be misleading and incomplete.
 */
export const flutterTestTargets = Object.freeze([
  Object.freeze({ name: 'testing_utils', directory: 'packages/testing_utils' }),
  Object.freeze({ name: 'design_system', directory: 'packages/design_system' }),
  Object.freeze({ name: 'mobile', directory: 'apps/mobile' }),
  Object.freeze({ name: 'admin', directory: 'apps/admin' }),
]);

const flutterExecutable = 'flutter';

function runFlutterCommand(target, arguments_) {
  const command = process.platform === 'win32' ? 'cmd.exe' : flutterExecutable;
  const commandArguments =
    process.platform === 'win32'
        // `call` returns control to cmd after Flutter's batch launcher exits.
        // These arguments are controlled by this module, not CLI input.
        ? ['/d', '/s', '/c', `call ${flutterExecutable}.bat ${arguments_.join(' ')}`]
        : arguments_;

  return new Promise((resolveCommand) => {
    const child = spawn(command, commandArguments, {
      cwd: resolve(repositoryRoot, target.directory),
      stdio: 'inherit',
      windowsHide: true,
    });

    child.once('error', (error) => {
      process.stderr.write(
        `Unable to run Flutter for ${target.name}: ${error.message}\n`,
      );
      resolveCommand(1);
    });
    child.once('exit', (code, signal) => {
      if (signal != null) {
        process.stderr.write(
          `Flutter ${arguments_.join(' ')} for ${target.name} ended by ${signal}.\n`,
        );
      }
      resolveCommand(code ?? 1);
    });
  });
}

/**
 * Runs each Flutter project from its own package directory.
 *
 * Tests always run. With `includeAnalyze`, all analysis completes before any
 * test begins, which makes the command appropriate for local quality gates.
 */
export async function runFlutterTests({
  includeAnalyze = false,
  runCommand = runFlutterCommand,
} = {}) {
  const commands = includeAnalyze ? [['analyze'], ['test']] : [['test']];

  for (const arguments_ of commands) {
    for (const target of flutterTestTargets) {
      const status = await runCommand(target, arguments_);
      if (status !== 0) {
        return status;
      }
    }
  }

  return 0;
}

export function parseRunnerArguments(arguments_) {
  if (arguments_.length === 0) {
    return { includeAnalyze: false };
  }
  if (arguments_.length === 1 && arguments_[0] === '--check') {
    return { includeAnalyze: true };
  }
  if (arguments_.length === 1 && arguments_[0] === '--help') {
    return { help: true };
  }
  return null;
}

function printUsage() {
  process.stdout.write(
    'Usage: node scripts/run_flutter_tests.mjs [--check]\n' +
      '  --check  Run flutter analyze for every target, then flutter test.\n',
  );
}

const isDirectExecution =
  process.argv[1] != null &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isDirectExecution) {
  const options = parseRunnerArguments(process.argv.slice(2));
  if (options == null) {
    printUsage();
    process.exitCode = 2;
  } else if (options.help === true) {
    printUsage();
  } else {
    process.exitCode = await runFlutterTests(options);
  }
}
