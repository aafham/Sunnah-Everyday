/// Wire values mirror the policy-defined PostgreSQL enums in BE-01.
enum SourcePermissionStatus {
  unknown('UNKNOWN'),
  requested('REQUESTED'),
  granted('GRANTED'),
  publicLicense('PUBLIC_LICENSE'),
  linkOnly('LINK_ONLY'),
  restricted('RESTRICTED'),
  expired('EXPIRED'),
  rejected('REJECTED');

  const SourcePermissionStatus(this.wireValue);

  final String wireValue;
}

enum SourceDisplayMode {
  linkOnly('LINK_ONLY'),
  licensedContent('LICENSED_CONTENT');

  const SourceDisplayMode(this.wireValue);

  final String wireValue;
}

enum SourceType {
  primaryText('PRIMARY_TEXT'),
  narrationAssessment('NARRATION_ASSESSMENT'),
  authoritativeExplanation('AUTHORITATIVE_EXPLANATION'),
  editorialSummary('EDITORIAL_SUMMARY');

  const SourceType(this.wireValue);

  final String wireValue;
}

enum HadithGrade {
  sahih('SAHIH'),
  hasan('HASAN'),
  daif('DAIF'),
  veryWeak('VERY_WEAK'),
  fabricated('FABRICATED'),
  disputed('DISPUTED'),
  ungraded('UNGRADED'),
  notApplicable('NOT_APPLICABLE');

  const HadithGrade(this.wireValue);

  final String wireValue;
}

enum PracticeClassification {
  sunnahRecommended('SUNNAH_RECOMMENDED'),
  adab('ADAB'),
  akhlaq('AKHLAQ'),
  obligatory('OBLIGATORY'),
  permissible('PERMISSIBLE'),
  propheticHabit('PROPHETIC_HABIT'),
  prophetSpecific('PROPHET_SPECIFIC'),
  contextSpecific('CONTEXT_SPECIFIC'),
  disputed('DISPUTED'),
  historicalInformation('HISTORICAL_INFORMATION'),
  dua('DUA'),
  dhikr('DHIKR');

  const PracticeClassification(this.wireValue);

  final String wireValue;
}

enum PropheticForm {
  qawliyyah('QAWLIYYAH'),
  filiiyyah('FI_LIYYAH'),
  taqririyyah('TAQRIRIYYAH'),
  mixed('MIXED'),
  notApplicable('NOT_APPLICABLE');

  const PropheticForm(this.wireValue);

  final String wireValue;
}

enum ContentWorkflowStatus {
  draft('DRAFT'),
  researched('RESEARCHED'),
  hadithReviewPending('HADITH_REVIEW_PENDING'),
  hadithVerified('HADITH_VERIFIED'),
  fiqhReviewPending('FIQH_REVIEW_PENDING'),
  fiqhReviewed('FIQH_REVIEWED'),
  languageReviewPending('LANGUAGE_REVIEW_PENDING'),
  languageReviewed('LANGUAGE_REVIEWED'),
  finalApprovalPending('FINAL_APPROVAL_PENDING'),
  approved('APPROVED'),
  scheduled('SCHEDULED'),
  published('PUBLISHED'),
  correctionPending('CORRECTION_PENDING'),
  corrected('CORRECTED'),
  suspended('SUSPENDED'),
  withdrawn('WITHDRAWN'),
  archived('ARCHIVED');

  const ContentWorkflowStatus(this.wireValue);

  final String wireValue;
}

enum ReviewScope {
  sourceHadith('SOURCE_HADITH'),
  fiqhContext('FIQH_CONTEXT'),
  language('LANGUAGE');

  const ReviewScope(this.wireValue);

  final String wireValue;
}

enum ContentImportMode {
  staging('STAGING');

  const ContentImportMode(this.wireValue);

  final String wireValue;
}

enum TranslationAvailability {
  complete('COMPLETE'),
  unavailable('UNAVAILABLE');

  const TranslationAvailability(this.wireValue);

  final String wireValue;
}

/// Metadata only: it records whether protected evidence text is present.
/// It never grants a right to display or reproduce that text.
enum EvidenceTextStatus {
  notIncluded('NOT_INCLUDED'),
  rightsReviewRequired('RIGHTS_REVIEW_REQUIRED'),
  displayRightsRecorded('DISPLAY_RIGHTS_RECORDED');

  const EvidenceTextStatus(this.wireValue);

  final String wireValue;
}
