/// All tunable numbers for ranking and timing live here and nowhere else.
/// Values match reference/logic.js (TUNE0).
class Tune {
  static const dueFloor = 0.6;
  static const chipPenalty = 0.6;
  static const gapBoost = 2.0;
  static const gapRatio = 4.0;
  static const trustChats = 5;
  static const historyDamp = 0.6;
  static const expCap = 90;
  static const chip15Max = 20;
  static const chip30Min = 20;
  static const chipLongMin = 50;
  static const lastN = 5;
  static const awakeStartHour = 8;
  static const awakeEndHour = 22;
  static const snoozeDays = 7;

  /// Group priority weights are all 1.0 in version 1; tune after real use.
  static const defaultGroupWeight = 1.0;

  /// Birthdays and dates within this many days show on Home.
  static const homeDatesDays = 14;
  static const groupIntervalDays = {'parents': 14, 'siblings': 21, 'friends': 30};
  /// "Roughly when did you last talk?" answers, in days ago.
  static const lastTalkedChoices = [
    ('A week', 7),
    ('Two weeks', 14),
    ('A month', 30),
    ('A few months', 90),
    ('Six months', 180),
    ('A year or more', 360),
  ];

  /// Used when the question is skipped.
  static const defaultLastTalkedDays = 180;

  /// After tapping Contact, the log popup defaults to that person this long.
  static const recentContactHours = 3;

  /// Chat length buckets from the duration slider (minutes).
  static const quickMaxMinutes = 20;
  static const catchupMaxMinutes = 45;
  static const lengthMinutes = {'quick': 15, 'catchup': 30, 'long': 60};
}
