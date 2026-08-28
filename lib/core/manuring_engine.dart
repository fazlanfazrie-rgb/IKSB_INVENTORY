class ManuringResult {
  const ManuringResult({required this.planned, required this.issued});
  final double planned;
  final double issued;
  double get balance => planned - issued;
  double get progress => planned == 0 ? 0 : issued / planned * 100;
  String get status {
    if (planned == 0) return 'NO PLAN';
    if (issued > planned) return 'OVER APPLIED';
    if (issued == planned) return 'COMPLETED';
    return 'PENDING';
  }
}

class ManuringEngine {
  static ManuringResult calculate({required double planned, required double issued}) =>
      ManuringResult(planned: planned, issued: issued);
}
