import { runContentValidationCli } from './validate_content.mjs';

// CNT-02 deliberately contains no database credentials, role gate or
// publication workflow. This executable validates a candidate then refuses to
// write it anywhere, preventing an accidental "import" from bypassing BE-03.
const validationExitCode = await runContentValidationCli(process.argv.slice(2));

if (validationExitCode === 0) {
  console.error(
    'Import refused: CNT-02 is a read-only STAGING/DRAFT preview. No records were written, approved, or published.',
  );
  process.exitCode = 3;
} else {
  process.exitCode = validationExitCode;
}
