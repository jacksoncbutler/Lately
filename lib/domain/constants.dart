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
  static const groupIntervalDays = {'parents': 14, 'siblings': 21, 'friends': 30};
  static const lengthMinutes = {'quick': 15, 'catchup': 30, 'long': 60};
}
