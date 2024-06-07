import Foundation

extension Calendar {

  /// Provides a Gregorian calendar set to the GMT time zone.
  static var gmtGregorian: Self? {
    var calendar = Calendar(identifier: .gregorian)
    guard let gmt = TimeZone.backportGmt else { return nil }
    calendar.timeZone = gmt
    return calendar
  }
}
