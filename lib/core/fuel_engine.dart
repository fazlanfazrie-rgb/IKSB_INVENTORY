class FuelResult {
  const FuelResult({required this.charging, required this.daily});
  final String charging;
  final Map<int, double> daily;
  double get total => daily.values.fold(0, (sum, value) => sum + value);
  double get avg {
    final used = daily.values.where((value) => value > 0).length;
    return used == 0 ? 0 : total / used;
  }
}

/// Native fuel matrix engine. Day keys are 1..31; missing days remain zero.
class FuelEngine {
  static FuelResult calculate({required String charging, required Map<int, double> daily}) {
    final normalized = <int, double>{};
    for (var day = 1; day <= 31; day++) {
      normalized[day] = daily[day] ?? 0;
    }
    return FuelResult(charging: charging.trim(), daily: normalized);
  }
}
