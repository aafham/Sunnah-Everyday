import assert from 'node:assert/strict';
import test from 'node:test';

import {
  flutterTestTargets,
  parseRunnerArguments,
  runFlutterTests,
} from './run_flutter_tests.mjs';

test('runner analyzes every target before running its tests', async () => {
  const calls = [];

  const status = await runFlutterTests({
    includeAnalyze: true,
    runCommand: async (target, arguments_) => {
      calls.push([target.name, ...arguments_]);
      return 0;
    },
  });

  assert.equal(status, 0);
  assert.deepEqual(calls, [
    ...flutterTestTargets.map((target) => [target.name, 'analyze']),
    ...flutterTestTargets.map((target) => [target.name, 'test']),
  ]);
});

test('runner stops at the first failing Flutter command', async () => {
  const calls = [];

  const status = await runFlutterTests({
    runCommand: async (target, arguments_) => {
      calls.push([target.name, ...arguments_]);
      return target.name === 'design_system' ? 1 : 0;
    },
  });

  assert.equal(status, 1);
  assert.deepEqual(calls, [
    ['testing_utils', 'test'],
    ['design_system', 'test'],
  ]);
});

test('runner only accepts documented command-line options', () => {
  assert.deepEqual(parseRunnerArguments([]), { includeAnalyze: false });
  assert.deepEqual(parseRunnerArguments(['--check']), { includeAnalyze: true });
  assert.deepEqual(parseRunnerArguments(['--help']), { help: true });
  assert.equal(parseRunnerArguments(['--unknown']), null);
});
