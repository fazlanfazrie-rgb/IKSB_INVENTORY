String periodKey(DateTime date) {
  const months = <String>[
    'JAN','FEB','MAR','APR','MAY','JUN',
    'JUL','AUG','SEP','OCT','NOV','DEC',
  ];
  return '${months[date.month - 1]}-${date.year.toString().substring(2)}';
}

String weekKey(DateTime date) {
  final day = date.day;
  if (day <= 7) return '1ST';
  if (day <= 14) return '2ND';
  if (day <= 21) return '3RD';
  return '4TH';
}
