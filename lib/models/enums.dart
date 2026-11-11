enum Equipment {
  bodyweight('Bodyweight'),
  freeWeights('Free weights');

  const Equipment(this.label);
  final String label;
}

enum Measure {
  reps('Reps'),
  time('Time'); // stored in seconds

  const Measure(this.label);
  final String label;
}

enum Motion {
  dynamic('Dynamic'),
  isometric('Isometric');

  const Motion(this.label);
  final String label;
}

/// Body parts in canonical order (declaration order).
enum BodyPart {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Forearms'),
  core('Core'),
  glutes('Glutes'),
  quads('Quads'),
  hamstrings('Hamstrings'),
  calves('Calves'),
  fullBody('Full body');

  const BodyPart(this.label);
  final String label;
}

enum SessionStatus {
  done('Done'),
  planned('Planned'),
  missed('Missed');

  const SessionStatus(this.label);
  final String label;
}

/// Labels only; values are never converted.
enum WeightUnit { kg, lb }

enum WeekStart {
  monday('Monday'),
  sunday('Sunday');

  const WeekStart(this.label);
  final String label;
}
