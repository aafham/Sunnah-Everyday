import 'content_enums.dart';

/// Required on every non-public staging candidate and fixture.
const stagingNonPublicationNotice = 'KANDUNGAN DEMO — TIDAK UNTUK PENERBITAN';

/// Server-owned fields that must never arrive through the draft template.
const serverManagedPublicationFields = <String>{
  'content_checksum',
  'immutable_after_publish',
  'published_at',
  'scheduled_at',
  'daily_schedule',
  'public_bundle_id',
  'publication_event_id',
  'approval_id',
};

/// Enforces the boundary between technical draft intake and human publication.
abstract final class StagingBoundary {
  static void requireStagingEnvelope({
    required ContentImportMode importMode,
    required String notice,
  }) {
    if (importMode != ContentImportMode.staging) {
      throw ArgumentError.value(
        importMode,
        'importMode',
        'Only STAGING import mode is supported by this contract.',
      );
    }
    if (notice != stagingNonPublicationNotice) {
      throw ArgumentError.value(
        notice,
        'notice',
        'Staging records must use the exact non-publication notice.',
      );
    }
  }

  static void requireDraftOnly({
    required ContentImportMode importMode,
    required ContentWorkflowStatus workflowStatus,
    required String notice,
  }) {
    requireStagingEnvelope(importMode: importMode, notice: notice);
    if (workflowStatus != ContentWorkflowStatus.draft) {
      throw ArgumentError.value(
        workflowStatus,
        'workflowStatus',
        'Imported records must start in DRAFT.',
      );
    }
  }

  static void rejectServerManagedFields(Iterable<String> fieldNames) {
    final prohibited = fieldNames
        .where(serverManagedPublicationFields.contains)
        .toList(growable: false);
    if (prohibited.isNotEmpty) {
      throw ArgumentError.value(
        prohibited,
        'fieldNames',
        'Draft imports cannot set server-managed publication fields.',
      );
    }
  }

  static void requireRightsCompatible({
    required SourcePermissionStatus permissionStatus,
    required SourceDisplayMode displayMode,
  }) {
    if (displayMode == SourceDisplayMode.licensedContent &&
        permissionStatus != SourcePermissionStatus.granted &&
        permissionStatus != SourcePermissionStatus.publicLicense) {
      throw ArgumentError(
        'LICENSED_CONTENT requires GRANTED or PUBLIC_LICENSE rights.',
      );
    }
  }
}

/// Common metadata for source, evidence and reviewer candidate records.
final class StagingEnvelope {
  StagingEnvelope({
    this.schemaVersion = '1',
    this.importMode = ContentImportMode.staging,
    required this.nonPublicationNotice,
  }) {
    if (schemaVersion != '1') {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Only schema version 1 is supported.',
      );
    }
    StagingBoundary.requireStagingEnvelope(
      importMode: importMode,
      notice: nonPublicationNotice,
    );
  }

  final String schemaVersion;
  final ContentImportMode importMode;
  final String nonPublicationNotice;

  Map<String, String> toContractMap() => <String, String>{
    'schema_version': schemaVersion,
    'import_mode': importMode.wireValue,
    'non_publication_notice': nonPublicationNotice,
  };
}
