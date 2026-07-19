import 'package:content_models/content_models.dart';
import 'package:test/test.dart';

void main() {
  test('policy enums retain their canonical wire values', () {
    expect(
      HadithGrade.values.map((grade) => grade.wireValue),
      equals(<String>[
        'SAHIH',
        'HASAN',
        'DAIF',
        'VERY_WEAK',
        'FABRICATED',
        'DISPUTED',
        'UNGRADED',
        'NOT_APPLICABLE',
      ]),
    );
    expect(
      ContentWorkflowStatus.values.map((status) => status.wireValue),
      containsAll(<String>['DRAFT', 'APPROVED', 'SCHEDULED', 'PUBLISHED']),
    );
    expect(
      PracticeClassification.values.map((value) => value.wireValue),
      containsAll(<String>['SUNNAH_RECOMMENDED', 'DISPUTED', 'DHIKR']),
    );
  });
}
