import 'package:content_models/content_models.dart';
import 'package:test/test.dart';

LocaleDraft _unavailableLocale() => LocaleDraft(
  availability: TranslationAvailability.unavailable,
  unavailableRationale: stagingNonPublicationNotice,
);

ContentImportDraft _draft({
  ContentWorkflowStatus workflowStatus = ContentWorkflowStatus.draft,
  SourcePermissionStatus rightsStatus = SourcePermissionStatus.linkOnly,
  SourceDisplayMode displayMode = SourceDisplayMode.linkOnly,
}) => ContentImportDraft(
  itemSlug: 'structural-test-item',
  versionNumber: 1,
  contentType: 'STRUCTURAL_TEST',
  categorySlug: 'structural-test-category',
  tagSlugs: const <String>[],
  classification: PracticeClassification.disputed,
  propheticForm: PropheticForm.notApplicable,
  audienceScopes: const <String>[],
  situationScopes: const <String>[],
  difficultyLevel: 1,
  hasScholarlyDifference: false,
  isProphetSpecific: false,
  requiresMedicalNote: false,
  malay: _unavailableLocale(),
  english: _unavailableLocale(),
  sourceRightsStatus: rightsStatus,
  displayMode: displayMode,
  sourceStableKeys: const <String>['structural-test-source'],
  evidenceKeys: const <String>['structural-test-evidence'],
  reviewerReferenceKeys: const <String>[],
  importMode: ContentImportMode.staging,
  workflowStatus: workflowStatus,
  nonPublicationNotice: stagingNonPublicationNotice,
);

void main() {
  test('a structural staging draft never becomes publication eligible', () {
    final draft = _draft();

    expect(draft.isPublicationEligible, isFalse);
    expect(draft.workflowStatus, ContentWorkflowStatus.draft);
    expect(draft.toContractMap()['schema_version'], '1');
    expect(
      (draft.toContractMap()['locales'] as Map<String, Object?>).keys,
      containsAll(<String>['ms', 'en']),
    );
    expect(draft.toContractMap(), isNot(contains('published_at')));
    expect(draft.toContractMap(), isNot(contains('daily_schedule')));
  });

  test('a staging import rejects a non-draft workflow state', () {
    expect(
      () => _draft(workflowStatus: ContentWorkflowStatus.scheduled),
      throwsArgumentError,
    );
  });

  test('an unavailable locale cannot carry unreviewed draft text', () {
    expect(
      () => LocaleDraft(
        availability: TranslationAvailability.unavailable,
        unavailableRationale: stagingNonPublicationNotice,
        title: 'STRUCTURAL_TEST',
      ),
      throwsArgumentError,
    );
  });

  test('a complete locale cannot carry an unavailable rationale', () {
    expect(
      () => LocaleDraft(
        availability: TranslationAvailability.complete,
        unavailableRationale: stagingNonPublicationNotice,
        title: 'STRUCTURAL_TEST',
        summary: 'STRUCTURAL_TEST',
        practicalSteps: 'STRUCTURAL_TEST',
        whenToPractise: 'STRUCTURAL_TEST',
        contextNote: 'STRUCTURAL_TEST',
        misunderstandingNote: 'STRUCTURAL_TEST',
        legalClassificationNote: 'STRUCTURAL_TEST',
      ),
      throwsArgumentError,
    );
  });

  test('licensed display cannot be created without recorded usable rights', () {
    expect(
      () => _draft(
        rightsStatus: SourcePermissionStatus.requested,
        displayMode: SourceDisplayMode.licensedContent,
      ),
      throwsArgumentError,
    );
  });

  test('draft metadata URLs require an absolute HTTP(S) host', () {
    expect(
      () => EvidenceDraft(
        staging: StagingEnvelope(
          nonPublicationNotice: stagingNonPublicationNotice,
        ),
        evidenceKey: 'structural-test-evidence',
        sourceStableKey: 'structural-test-source',
        sourcePermissionRevision: 1,
        evidenceType: 'STRUCTURAL_TEST',
        sourceLocator: 'STRUCTURAL_TEST',
        hadithGrade: HadithGrade.notApplicable,
        graderReference: 'STRUCTURAL_TEST',
        arabicDisplayStatus: EvidenceTextStatus.notIncluded,
        translationStatus: EvidenceTextStatus.notIncluded,
        rightsStatus: SourcePermissionStatus.linkOnly,
        displayMode: SourceDisplayMode.linkOnly,
        sourceUrl: Uri(scheme: 'https'),
      ),
      throwsArgumentError,
    );
  });

  test('draft metadata URLs reject embedded credentials', () {
    expect(
      () => EvidenceDraft(
        staging: StagingEnvelope(
          nonPublicationNotice: stagingNonPublicationNotice,
        ),
        evidenceKey: 'structural-test-evidence',
        sourceStableKey: 'structural-test-source',
        sourcePermissionRevision: 1,
        evidenceType: 'STRUCTURAL_TEST',
        sourceLocator: 'STRUCTURAL_TEST',
        hadithGrade: HadithGrade.notApplicable,
        graderReference: 'STRUCTURAL_TEST',
        arabicDisplayStatus: EvidenceTextStatus.notIncluded,
        translationStatus: EvidenceTextStatus.notIncluded,
        rightsStatus: SourcePermissionStatus.linkOnly,
        displayMode: SourceDisplayMode.linkOnly,
        sourceUrl: Uri.parse('https://structural:fixture@example.invalid'),
      ),
      throwsArgumentError,
    );
  });

  test('draft reviewers cannot be activated by intake metadata', () {
    expect(
      () => ReviewerDraft(
        staging: StagingEnvelope(
          nonPublicationNotice: stagingNonPublicationNotice,
        ),
        reviewerCode: 'structural-test-reviewer',
        publicDisplayName: stagingNonPublicationNotice,
        restrictedProfileReference: stagingNonPublicationNotice,
        qualificationType: stagingNonPublicationNotice,
        specialism: stagingNonPublicationNotice,
        qualificationEvidenceReference: stagingNonPublicationNotice,
        reviewScope: ReviewScope.language,
        isActive: true,
      ),
      throwsArgumentError,
    );
  });

  test('metadata drafts retain their validated staging envelope', () {
    final staging = StagingEnvelope(
      nonPublicationNotice: stagingNonPublicationNotice,
    );
    final source = SourceRegisterDraft(
      staging: staging,
      sourceStableKey: 'structural-test-source',
      sourceName: 'STRUCTURAL_TEST',
      ownerName: 'STRUCTURAL_TEST',
      sourceType: SourceType.editorialSummary,
      bibliographicLocator: 'STRUCTURAL_TEST',
      edition: 'STRUCTURAL_TEST',
      accessedAt: DateTime.utc(2099),
      reviewedAt: DateTime.utc(2099),
      languageCode: 'zz',
      permissionRevision: 1,
      permissionStatus: SourcePermissionStatus.linkOnly,
      displayMode: SourceDisplayMode.linkOnly,
      rightsBasis: 'STRUCTURAL_TEST',
      permissionScope: 'STRUCTURAL_TEST',
      usageNotes: 'STRUCTURAL_TEST',
      reviewedByReference: 'structural-test-reviewer',
    );
    final evidence = EvidenceDraft(
      staging: staging,
      evidenceKey: 'structural-test-evidence',
      sourceStableKey: source.sourceStableKey,
      sourcePermissionRevision: 1,
      evidenceType: 'STRUCTURAL_TEST',
      sourceLocator: 'STRUCTURAL_TEST',
      hadithGrade: HadithGrade.notApplicable,
      graderReference: 'STRUCTURAL_TEST',
      arabicDisplayStatus: EvidenceTextStatus.notIncluded,
      translationStatus: EvidenceTextStatus.notIncluded,
      rightsStatus: SourcePermissionStatus.linkOnly,
      displayMode: SourceDisplayMode.linkOnly,
    );
    final reviewer = ReviewerDraft(
      staging: staging,
      reviewerCode: 'structural-test-reviewer',
      publicDisplayName: 'STRUCTURAL_TEST',
      restrictedProfileReference: 'STRUCTURAL_TEST',
      qualificationType: 'STRUCTURAL_TEST',
      specialism: 'STRUCTURAL_TEST',
      qualificationEvidenceReference: 'STRUCTURAL_TEST',
      reviewScope: ReviewScope.language,
      isActive: false,
    );

    expect(source.toContractMap()['schema_version'], '1');
    expect(evidence.toContractMap()['translation_status'], 'NOT_INCLUDED');
    expect(reviewer.toContractMap()['is_active'], isFalse);
  });

  test(
    'content-evidence links preserve ordering without publication fields',
    () {
      final link = ContentEvidenceDraft(
        staging: StagingEnvelope(
          nonPublicationNotice: stagingNonPublicationNotice,
        ),
        itemSlug: 'structural-test-item',
        versionNumber: 1,
        evidenceKey: 'structural-test-evidence',
        displayOrder: 0,
        isPrimary: true,
      );

      expect(link.toContractMap()['display_order'], 0);
      expect(link.toContractMap(), isNot(contains('published_at')));
    },
  );
}
