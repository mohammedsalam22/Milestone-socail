enum ExamType {
  exam1('Exam 1'),
  exam2('Exam 2'),
  exam3('Exam 3'),
  exam4('Exam 4'),
  oralTest('Oral Test'),
  writtenTest('Written Test');

  const ExamType(this.displayName);

  final String displayName;

  static ExamType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'exam 1':
      case 'exam1':
        return ExamType.exam1;
      case 'exam 2':
      case 'exam2':
        return ExamType.exam2;
      case 'exam 3':
      case 'exam3':
        return ExamType.exam3;
      case 'exam 4':
      case 'exam4':
        return ExamType.exam4;
      case 'oral test':
      case 'oraltest':
        return ExamType.oralTest;
      case 'written test':
      case 'writtentest':
        return ExamType.writtenTest;
      default:
        return ExamType.writtenTest; // Default fallback
    }
  }

  static List<ExamType> get allTypes => ExamType.values;
}
