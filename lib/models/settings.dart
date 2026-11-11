import 'enums.dart';

class AppSettings {
  const AppSettings({this.unit = WeightUnit.kg, this.weekStart = WeekStart.monday, this.appearance = Appearance.system});

  final WeightUnit unit;
  final WeekStart weekStart;
  final Appearance appearance;

  AppSettings copyWith({WeightUnit? unit, WeekStart? weekStart, Appearance? appearance}) => AppSettings(
        unit: unit ?? this.unit,
        weekStart: weekStart ?? this.weekStart,
        appearance: appearance ?? this.appearance,
      );

  Map<String, dynamic> toJson() => {'unit': unit.name, 'weekStart': weekStart.name, 'appearance': appearance.name};

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        unit: WeightUnit.values.asNameMap()[j['unit']] ?? WeightUnit.kg,
        weekStart: WeekStart.values.asNameMap()[j['weekStart']] ?? WeekStart.monday,
        appearance: Appearance.values.asNameMap()[j['appearance']] ?? Appearance.system,
      );
}
