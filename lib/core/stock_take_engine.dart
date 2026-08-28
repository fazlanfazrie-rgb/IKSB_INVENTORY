class StockTakeResult {
  const StockTakeResult({required this.system, required this.physical});
  final double system;
  final double physical;
  double get variance => physical - system;
  String get status => variance == 0 ? 'TALLY' : variance > 0 ? 'OVER' : 'SHORT';
}

class StockTakeEngine {
  static StockTakeResult calculate({required double system, required double physical}) =>
      StockTakeResult(system: system, physical: physical);
}
