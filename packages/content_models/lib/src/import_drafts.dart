import 'content_enums.dart';
import 'staging_boundary.dart';

final RegExp _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
final RegExp _localeCodePattern = RegExp(r'^[a-z]{2}(?:-[A-Z]{2})?$');

bool _isBlank(String value) => value.trim().isEmpty;

void _requireSlug(String value, String fieldName) {
  if (value.length > 120 || !_slugPattern.hasMatch(value)) {
    throw ArgumentError.value(value, fieldName, 'Must be a lowercase slug.');
  }
}

void _requireText(String value, String fieldName) {
  if (_isBlank(value)) {
    throw ArgumentError.value(value, fieldName, 'Must not be blank.');
  }
}

void _requireBoundedText(String value, String fieldName, int maximumLength) {
  _requireText(value, fieldName);
  if (value.length > maximumLength) {
    throw ArgumentError.value(
      value,
      fieldName,
      'Must be no longer than $maximumLength characters.',
    );
  }
}

void _requireOptionalText(String? value, String fieldName, int maximumLength) {
  if (value != null && (_isBlank(value) || value.length > maximumLength)) {
    throw ArgumentError.value(
      value,
      fieldName,
      'Must be non-blank and no longer than $maximumLength characters.',
    );
  }
}

void _requireScopeList(List<String> values, String fieldName) {
  if (values.length != values.toSet().length) {
    throw ArgumentError.value(
      values,
      fieldName,
      'Must not contain duplicates.',
    );
  }
  for (final value in values) {
    if (_isBlank(value) || value.length > 120) {
      throw ArgumentError.value(
        value,
        fieldName,
        'Each value must be non-blank and no longer than 120 characters.',
      );
    }
  }
}

void _requireUniqueSlugs(List<String> values, String fieldName) {
  if (values.length != values.toSet().length) {
    throw ArgumentError.value(
      values,
      fieldName,
      'Must not contain duplicates.',
    );
  }
  for (final value in values) {
    _requireSlug(value, fieldName);
  }
}

void _requireHttpUri(Uri? value, String fieldName) {
  if (value != null && value.scheme != 'http' && value.scheme != 'https') {
    throw ArgumentError.value(value, fieldName, 'Must use HTTP or HTTPS.');
  }
}

String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;

/// A locale's draft fields are either complete or explicitly unavailable.
final class LocaleDraft {
  LocaleDraft({
    required this.availability,
    this.unavailableRationale,
    this.title,
    this.summary,
    this.practicalSteps,
    this.whenToPractise,
    this.contextNote,
    this.misunderstandingNote,
    this.legalClassificationNote,
  }) {
    if (availability == TranslationAvailability.unavailable) {
      if (unavailableRationale == null || _isBlank(unavailableRationale!)) {
        throw ArgumentError.value(
          unavailableRationale,
          'unavailableRationale',
          'An unavailable locale needs a recorded rationale.',
        );
      }
      _requireBoundedText(unavailableRationale!, 'unavailableRationale', 500);
      return;
    }

    for (final field in <({String? value, String name, int maximum})>[
      (value: title, name: 'title', maximum: 500),
      (value: summary, name: 'summary', maximum: 4000),
      (value: practicalSteps, name: 'practicalSteps', maximum: 8000),
      (value: whenToPractise, name: 'whenToPractise', maximum: 2000),
      (value: contextNote, name: 'contextNote', maximum: 4000),
      (
        value: misunderstandingNote,
        name: 'misunderstandingNote',
        maximum: 4000,
      ),
      (
        value: legalClassificationNote,
        name: 'legalClassificationNote',
        maximum: 4000,
      ),
    ]) {
      if (field.value == null || _isBlank(field.value!)) {
        throw ArgumentError(
          'A complete locale must contain every required draft field.',
        );
      }
      _requireBoundedText(field.value!, field.name, field.maximum);
    }
  }

  final TranslationAvailability availability;
  final String? unavailableRationale;
  final String? title;
  final String? summary;
  final String? practicalSteps;
  final String? whenToPractise;
  final String? contextNote;
  final String? misunderstandingNote;
  final String? legalClassificationNote;

  Map<String, Object?> toContractMap() => <String, Object?>{
    'availability': availability.wireValue,
    'unavailable_rationale': unavailableRationale,
    'title': title,
    'summary': summary,
    'practical_steps': practicalSteps,
    'when_to_practise': whenToPractise,
    'context_note': contextNote,
    'misunderstanding_note': misunderstandingNote,
    'legal_classification_note': legalClassificationNote,
  };
}

/// A source permission reference used only for staged intake metadata.
final class SourceRegisterDraft {
  SourceRegisterDraft({
    required this.staging,
    required this.sourceStableKey,
    required this.sourceName,
    required this.ownerName,
    required this.sourceType,
    required this.bibliographicLocator,
    required this.edition,
    required this.accessedAt,
    required this.reviewedAt,
    required this.languageCode,
    required this.permissionRevision,
    required this.permissionStatus,
    required this.displayMode,
    required this.rightsBasis,
    required this.permissionScope,
    required this.usageNotes,
    required this.reviewedByReference,
    this.sourceUrl,
    this.licence,
    this.documentReference,
    this.attributionText,
    this.permissionExpiresAt,
  }) {
    _requireSlug(sourceStableKey, 'sourceStableKey');
    _requireBoundedText(sourceName, 'sourceName', 500);
    _requireBoundedText(ownerName, 'ownerName', 500);
    _requireBoundedText(bibliographicLocator, 'bibliographicLocator', 1000);
    _requireBoundedText(edition, 'edition', 500);
    _requireBoundedText(languageCode, 'languageCode', 32);
    _requireBoundedText(rightsBasis, 'rightsBasis', 1000);
    _requireBoundedText(permissionScope, 'permissionScope', 2000);
    _requireBoundedText(usageNotes, 'usageNotes', 4000);
    _requireSlug(reviewedByReference, 'reviewedByReference');
    _requireHttpUri(sourceUrl, 'sourceUrl');
    _requireOptionalText(licence, 'licence', 1000);
    _requireOptionalText(documentReference, 'documentReference', 500);
    _requireOptionalText(attributionText, 'attributionText', 2000);
    if (permissionRevision < 1) {
      throw ArgumentError.value(
        permissionRevision,
        'permissionRevision',
        'Must be greater than zero.',
      );
    }
    if (reviewedAt.isBefore(accessedAt)) {
      throw ArgumentError('A source cannot be reviewed before it is accessed.');
    }
    if (permissionExpiresAt != null &&
        permissionExpiresAt!.isBefore(reviewedAt)) {
      throw ArgumentError(
        'A source permission cannot expire before its review date.',
      );
    }
    StagingBoundary.requireRightsCompatible(
      permissionStatus: permissionStatus,
      displayMode: displayMode,
    );
  }

  final StagingEnvelope staging;
  final String sourceStableKey;
  final String sourceName;
  final String ownerName;
  final SourceType sourceType;
  final String bibliographicLocator;
  final String edition;
  final DateTime accessedAt;
  final DateTime reviewedAt;
  final String languageCode;
  final int permissionRevision;
  final SourcePermissionStatus permissionStatus;
  final SourceDisplayMode displayMode;
  final String rightsBasis;
  final String permissionScope;
  final String usageNotes;
  final String reviewedByReference;
  final Uri? sourceUrl;
  final String? licence;
  final String? documentReference;
  final String? attributionText;
  final DateTime? permissionExpiresAt;

  Map<String, Object?> toContractMap() => <String, Object?>{
    ...staging.toContractMap(),
    'source_stable_key': sourceStableKey,
    'source_name': sourceName,
    'owner_name': ownerName,
    'source_type': sourceType.wireValue,
    'source_url': sourceUrl?.toString(),
    'bibliographic_locator': bibliographicLocator,
    'edition': edition,
    'language_code': languageCode,
    'accessed_at': _dateOnly(accessedAt),
    'reviewed_at': _dateOnly(reviewedAt),
    'permission_revision': permissionRevision,
    'permission_status': permissionStatus.wireValue,
    'display_mode': displayMode.wireValue,
    'rights_basis': rightsBasis,
    'licence': licence,
    'permission_scope': permissionScope,
    'document_reference': documentReference,
    'usage_notes': usageNotes,
    'attribution_text': attributionText,
    'permission_expires_at': permissionExpiresAt == null
        ? null
        : _dateOnly(permissionExpiresAt!),
    'reviewed_by_reference': reviewedByReference,
  };
}

/// An evidence reference preserves upstream metadata; it does not grade it.
final class EvidenceDraft {
  EvidenceDraft({
    required this.staging,
    required this.evidenceKey,
    required this.sourceStableKey,
    required this.sourcePermissionRevision,
    required this.evidenceType,
    required this.sourceLocator,
    required this.hadithGrade,
    required this.graderReference,
    required this.arabicDisplayStatus,
    required this.translationStatus,
    required this.rightsStatus,
    required this.displayMode,
    this.sourceUrl,
    this.collectionName,
    this.bookName,
    this.chapterName,
    this.referenceNumber,
    this.narrator,
    this.verifiedOn,
    this.verificationNote,
  }) {
    _requireSlug(evidenceKey, 'evidenceKey');
    _requireSlug(sourceStableKey, 'sourceStableKey');
    _requireBoundedText(evidenceType, 'evidenceType', 120);
    _requireBoundedText(sourceLocator, 'sourceLocator', 1000);
    _requireBoundedText(graderReference, 'graderReference', 500);
    _requireHttpUri(sourceUrl, 'sourceUrl');
    _requireOptionalText(collectionName, 'collectionName', 500);
    _requireOptionalText(bookName, 'bookName', 500);
    _requireOptionalText(chapterName, 'chapterName', 500);
    _requireOptionalText(referenceNumber, 'referenceNumber', 500);
    _requireOptionalText(narrator, 'narrator', 500);
    _requireOptionalText(verificationNote, 'verificationNote', 2000);
    if (sourcePermissionRevision < 1) {
      throw ArgumentError.value(
        sourcePermissionRevision,
        'sourcePermissionRevision',
        'Must be greater than zero.',
      );
    }
    StagingBoundary.requireRightsCompatible(
      permissionStatus: rightsStatus,
      displayMode: displayMode,
    );
  }

  final StagingEnvelope staging;
  final String evidenceKey;
  final String sourceStableKey;
  final int sourcePermissionRevision;
  final String evidenceType;
  final String sourceLocator;
  final HadithGrade hadithGrade;
  final String graderReference;
  final EvidenceTextStatus arabicDisplayStatus;
  final EvidenceTextStatus translationStatus;
  final SourcePermissionStatus rightsStatus;
  final SourceDisplayMode displayMode;
  final Uri? sourceUrl;
  final String? collectionName;
  final String? bookName;
  final String? chapterName;
  final String? referenceNumber;
  final String? narrator;
  final DateTime? verifiedOn;
  final String? verificationNote;

  Map<String, Object?> toContractMap() => <String, Object?>{
    ...staging.toContractMap(),
    'evidence_key': evidenceKey,
    'source_stable_key': sourceStableKey,
    'source_permission_revision': sourcePermissionRevision,
    'evidence_type': evidenceType,
    'source_locator': sourceLocator,
    'source_url': sourceUrl?.toString(),
    'collection_name': collectionName,
    'book_name': bookName,
    'chapter_name': chapterName,
    'reference_number': referenceNumber,
    'narrator': narrator,
    'hadith_grade': hadithGrade.wireValue,
    'grader_reference': graderReference,
    'arabic_display_status': arabicDisplayStatus.wireValue,
    'translation_status': translationStatus.wireValue,
    'verification_date': verifiedOn == null ? null : _dateOnly(verifiedOn!),
    'verification_note': verificationNote,
    'rights_status': rightsStatus.wireValue,
    'display_mode': displayMode.wireValue,
  };
}

/// A reviewer intake reference cannot activate or approve a reviewer.
final class ReviewerDraft {
  ReviewerDraft({
    required this.staging,
    required this.reviewerCode,
    required this.publicDisplayName,
    required this.restrictedProfileReference,
    required this.qualificationType,
    required this.specialism,
    required this.qualificationEvidenceReference,
    required this.reviewScope,
    required this.isActive,
    this.localeCode,
    this.verifiedAt,
  }) {
    _requireSlug(reviewerCode, 'reviewerCode');
    _requireBoundedText(publicDisplayName, 'publicDisplayName', 120);
    _requireBoundedText(
      restrictedProfileReference,
      'restrictedProfileReference',
      500,
    );
    _requireBoundedText(qualificationType, 'qualificationType', 500);
    _requireBoundedText(specialism, 'specialism', 500);
    _requireBoundedText(
      qualificationEvidenceReference,
      'qualificationEvidenceReference',
      500,
    );
    _requireOptionalText(localeCode, 'localeCode', 16);
    if (localeCode != null && !_localeCodePattern.hasMatch(localeCode!)) {
      throw ArgumentError.value(
        localeCode,
        'localeCode',
        'Must use a supported locale-code shape.',
      );
    }
    if (isActive) {
      throw ArgumentError.value(
        isActive,
        'isActive',
        'An intake draft cannot activate a reviewer.',
      );
    }
  }

  final StagingEnvelope staging;
  final String reviewerCode;
  final String publicDisplayName;
  final String restrictedProfileReference;
  final String qualificationType;
  final String specialism;
  final String qualificationEvidenceReference;
  final ReviewScope reviewScope;
  final bool isActive;
  final String? localeCode;
  final DateTime? verifiedAt;

  Map<String, Object?> toContractMap() => <String, Object?>{
    ...staging.toContractMap(),
    'reviewer_code': reviewerCode,
    'public_display_name': publicDisplayName,
    'restricted_profile_reference': restrictedProfileReference,
    'qualification_type': qualificationType,
    'specialism': specialism,
    'qualification_evidence_reference': qualificationEvidenceReference,
    'review_scope': reviewScope.wireValue,
    'locale_code': localeCode,
    'verified_at': verifiedAt?.toUtc().toIso8601String(),
    'is_active': isActive,
  };
}

/// A draft-only logical link from a candidate version to evidence metadata.
final class ContentEvidenceDraft {
  ContentEvidenceDraft({
    required this.staging,
    required this.itemSlug,
    required this.versionNumber,
    required this.evidenceKey,
    required this.displayOrder,
    required this.isPrimary,
  }) {
    _requireSlug(itemSlug, 'itemSlug');
    _requireSlug(evidenceKey, 'evidenceKey');
    if (versionNumber < 1) {
      throw ArgumentError.value(
        versionNumber,
        'versionNumber',
        'Must be greater than zero.',
      );
    }
    if (displayOrder < 0) {
      throw ArgumentError.value(
        displayOrder,
        'displayOrder',
        'Must not be negative.',
      );
    }
  }

  final StagingEnvelope staging;
  final String itemSlug;
  final int versionNumber;
  final String evidenceKey;
  final int displayOrder;
  final bool isPrimary;

  Map<String, Object?> toContractMap() => <String, Object?>{
    ...staging.toContractMap(),
    'item_slug': itemSlug,
    'version_number': versionNumber,
    'evidence_key': evidenceKey,
    'display_order': displayOrder,
    'is_primary': isPrimary,
  };
}

/// A staged content candidate. It cannot be scheduled, approved or published.
final class ContentImportDraft {
  ContentImportDraft({
    required this.itemSlug,
    required this.versionNumber,
    required this.contentType,
    required this.categorySlug,
    required List<String> tagSlugs,
    required this.classification,
    required this.propheticForm,
    required List<String> audienceScopes,
    required List<String> situationScopes,
    required this.difficultyLevel,
    this.frequencyLabel,
    required this.hasScholarlyDifference,
    required this.isProphetSpecific,
    required this.requiresMedicalNote,
    required this.malay,
    required this.english,
    required this.sourceRightsStatus,
    required this.displayMode,
    required List<String> sourceStableKeys,
    required List<String> evidenceKeys,
    required List<String> reviewerReferenceKeys,
    required this.importMode,
    required this.workflowStatus,
    required this.nonPublicationNotice,
  }) : audienceScopes = List.unmodifiable(audienceScopes),
       situationScopes = List.unmodifiable(situationScopes),
       tagSlugs = List.unmodifiable(tagSlugs),
       sourceStableKeys = List.unmodifiable(sourceStableKeys),
       evidenceKeys = List.unmodifiable(evidenceKeys),
       reviewerReferenceKeys = List.unmodifiable(reviewerReferenceKeys) {
    _requireSlug(itemSlug, 'itemSlug');
    _requireText(contentType, 'contentType');
    if (contentType.length > 120) {
      throw ArgumentError.value(
        contentType,
        'contentType',
        'Must be no longer than 120 characters.',
      );
    }
    _requireSlug(categorySlug, 'categorySlug');
    _requireUniqueSlugs(tagSlugs, 'tagSlugs');
    _requireScopeList(audienceScopes, 'audienceScopes');
    _requireScopeList(situationScopes, 'situationScopes');
    _requireOptionalText(frequencyLabel, 'frequencyLabel', 120);
    if (versionNumber < 1) {
      throw ArgumentError.value(
        versionNumber,
        'versionNumber',
        'Must be greater than zero.',
      );
    }
    if (difficultyLevel < 1 || difficultyLevel > 5) {
      throw ArgumentError.value(
        difficultyLevel,
        'difficultyLevel',
        'Must be between 1 and 5.',
      );
    }
    if (sourceStableKeys.isEmpty || evidenceKeys.isEmpty) {
      throw ArgumentError(
        'A staged candidate needs source and evidence references.',
      );
    }
    _requireUniqueSlugs(sourceStableKeys, 'sourceStableKeys');
    _requireUniqueSlugs(evidenceKeys, 'evidenceKeys');
    _requireUniqueSlugs(reviewerReferenceKeys, 'reviewerReferenceKeys');
    StagingBoundary.requireDraftOnly(
      importMode: importMode,
      workflowStatus: workflowStatus,
      notice: nonPublicationNotice,
    );
    StagingBoundary.requireRightsCompatible(
      permissionStatus: sourceRightsStatus,
      displayMode: displayMode,
    );
  }

  final String itemSlug;
  final int versionNumber;
  final String contentType;
  final String categorySlug;
  final List<String> tagSlugs;
  final PracticeClassification classification;
  final PropheticForm propheticForm;
  final List<String> audienceScopes;
  final List<String> situationScopes;
  final int difficultyLevel;
  final String? frequencyLabel;
  final bool hasScholarlyDifference;
  final bool isProphetSpecific;
  final bool requiresMedicalNote;
  final LocaleDraft malay;
  final LocaleDraft english;
  final SourcePermissionStatus sourceRightsStatus;
  final SourceDisplayMode displayMode;
  final List<String> sourceStableKeys;
  final List<String> evidenceKeys;
  final List<String> reviewerReferenceKeys;
  final ContentImportMode importMode;
  final ContentWorkflowStatus workflowStatus;
  final String nonPublicationNotice;

  /// This contract never makes a staged candidate eligible for publication.
  bool get isPublicationEligible => false;

  Map<String, Object?> toContractMap() => <String, Object?>{
    'schema_version': '1',
    'import_mode': importMode.wireValue,
    'non_publication_notice': nonPublicationNotice,
    'workflow_status': workflowStatus.wireValue,
    'item_slug': itemSlug,
    'version_number': versionNumber,
    'content_type': contentType,
    'category_slug': categorySlug,
    'tag_slugs': tagSlugs,
    'classification': classification.wireValue,
    'prophetic_form': propheticForm.wireValue,
    'audience_scopes': audienceScopes,
    'situation_scopes': situationScopes,
    'difficulty_level': difficultyLevel,
    'frequency_label': frequencyLabel,
    'has_scholarly_difference': hasScholarlyDifference,
    'is_prophet_specific': isProphetSpecific,
    'requires_medical_note': requiresMedicalNote,
    'locales': <String, Object?>{
      'ms': malay.toContractMap(),
      'en': english.toContractMap(),
    },
    'source_rights_status': sourceRightsStatus.wireValue,
    'display_mode': displayMode.wireValue,
    'source_stable_keys': sourceStableKeys,
    'evidence_keys': evidenceKeys,
    'reviewer_reference_keys': reviewerReferenceKeys,
  };
}
