import 'enums.dart';

class AppSettings {
  const AppSettings({this.unit = WeightUnit.kg, this.weekStart = WeekStart.monday});

  final WeightUnit unit;
  final WeekStart weekStart;

  AppSettings copyWith({WeightUnit? unit, WeekStart? weekStart}) =>
      AppSettings(unit: unit ?? this.unit, weekStart: weekStart ?? this.weekStart);

  Map<String, dynamic> toJson() => {'unit': unit.name, 'weekStart': weekStart.name};

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        unit: WeightUnit.values.asNameMap()[j['unit']] ?? WeightUnit.kg,
        weekStart: WeekStart.values.asNameMap()[j['weekStart']] ?? WeekStart.monday,
      );
}
