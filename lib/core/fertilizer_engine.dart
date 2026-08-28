class FertilizerItem {
  const FertilizerItem({required this.code, required this.name, required this.group, required this.supplier, required this.uom});
  final String code, name, group, supplier, uom;
}

class FertilizerEngine {
  static FertilizerItem? find(Iterable<FertilizerItem> items, String code) {
    for (final item in items) {
      if (item.code.trim() == code.trim()) return item;
    }
    return null;
  }

  static double kg({required double quantity, required double kgPerUnit}) => quantity * kgPerUnit;
}
