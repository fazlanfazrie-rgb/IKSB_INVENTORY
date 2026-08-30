class ManuringResult {
  const ManuringResult({required this.planned, required this.issued});
  final double planned;
  final double issued;

  double get balance => planned - issued;

  /// Excel-style percentage calculation with deterministic numeric precision.
  double get progress => planned == 0 ? 0 : _round(issued / planned * 100);

  String get status {
    if (planned == 0) return 'NO PLAN';
    if (issued > planned) return 'OVER APPLIED';
    if (issued == planned) return 'COMPLETED';
    return 'PENDING';
  }

  static double _round(double value) =>
      double.parse(value.toStringAsFixed(10));
}

class ManuringEngine {
  static ManuringResult calculate({
    required double planned,
    required double issued,
  }) =>
      ManuringResult(planned: planned, issued: issued);
}
