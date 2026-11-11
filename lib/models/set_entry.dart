import 'ids.dart';

/// One set: reps or seconds ([value]) and a weight. For bodyweight exercises the
/// weight is the added load ("BW + weight"). Null means the field is empty.
class SetEntry {
  SetEntry({String? id, this.value, this.weight}) : id = id ?? newId();

  final String id;
  final int? value;
  final double? weight;

  SetEntry withValue(int? v) => SetEntry(id: id, value: v, weight: weight);
  SetEntry withWeight(double? w) => SetEntry(id: id, value: value, weight: w);

  /// A copy with a fresh id, used by "Add set".
  SetEntry duplicate() => SetEntry(value: value, weight: weight);

  Map<String, dynamic> toJson() => {'id': id, 'value': value, 'weight': weight};

  factory SetEntry.fromJson(Map<String, dynamic> j) => SetEntry(
        id: j['id'] as String,
        value: (j['value'] as num?)?.toInt(),
        weight: (j['weight'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) => other is SetEntry && other.id == id && other.value == value && other.weight == weight;

  @override
  int get hashCode => Object.hash(id, value, weight);
}
