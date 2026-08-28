class ControlFinding {
  const ControlFinding({required this.code, required this.message, required this.severity});
  final String code;
  final String message;
  final String severity;
}

class ControlEngine {
  static List<ControlFinding> validateBalance(double balance) {
    if (balance < 0) {
      return const [ControlFinding(code: 'NEGATIVE_STOCK', message: 'System balance is below zero; investigation required.', severity: 'HIGH')];
    }
    return const [];
  }

  static List<ControlFinding> validateQuantity({required double receive, required double issue}) {
    final findings = <ControlFinding>[];
    if (receive < 0) {
      findings.add(const ControlFinding(code: 'NEGATIVE_RECEIVE', message: 'Receive quantity cannot be negative.', severity: 'HIGH'));
    }
    if (issue < 0) {
      findings.add(const ControlFinding(code: 'NEGATIVE_ISSUE', message: 'Issue quantity cannot be negative.', severity: 'HIGH'));
    }
    if (receive > 0 && issue > 0) {
      findings.add(const ControlFinding(code: 'MIXED_MOVEMENT', message: 'Receive and issue should be separate transactions.', severity: 'MEDIUM'));
    }
    return findings;
  }
}
