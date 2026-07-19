import 'package:content_models/content_models.dart';
import 'package:test/test.dart';

void main() {
  test('the exact non-publication notice is mandatory', () {
    expect(
      () => StagingBoundary.requireDraftOnly(
        importMode: ContentImportMode.staging,
        workflowStatus: ContentWorkflowStatus.draft,
        notice: 'not a publication marker',
      ),
      throwsArgumentError,
    );
  });

  test('server-managed publication fields are rejected from a draft', () {
    expect(
      () => StagingBoundary.rejectServerManagedFields(<String>[
        'item_slug',
        'published_at',
        'approval_id',
      ]),
      throwsArgumentError,
    );
  });
}
