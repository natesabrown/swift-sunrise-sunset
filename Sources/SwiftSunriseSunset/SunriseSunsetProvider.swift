import Foundation

/// Convenience typealias that describes the parameters necessary to return a `Date?` for a sunrise or sunset.
public typealias SunriseSunsetEquation = (
  _ year: Int, _ month: Int, _ day: Int, _ latitude: Double, _ longitude: Double
) -> Date?

/// Encapsulates logic for getting the sunrise and sunset for a location on a day.
public struct SunriseSunsetProvider {

  let sunrise: SunriseSunsetEquation
  let sunset: SunriseSunsetEquation

  /// Initializes a ``SunriseSunsetProvider``.
  /// - Parameters:
  ///   - sunrise: A closure that returns a `Date?` representing the time of sunrise on a given day at a given location.
  ///   If there is no valid sunrise, this should return `nil`.
  ///   - sunset: A closure that returns a `Date?` representing the time of sunset on a given day at a given location.
  ///   If there is no valid sunset, this should return `nil`.
  public init(sunrise: @escaping SunriseSunsetEquation, sunset: @escaping SunriseSunsetEquation) {
    self.sunrise = sunrise
    self.sunset = sunset
  }
}

extension SunriseSunsetProvider {

  func sunrise(
    on date: Date,
    in timeZone: TimeZone,
    latitude: Double,
    longitude: Double
  ) -> Date? {

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    guard let year = components.year, let month = components.month, let day = components.day else {
      return nil
    }

    return sunrise(
      year,
      month,
      day,
      latitude,
      longitude
    )
  }

  func sunset(
    on date: Date,
    in timeZone: TimeZone,
    latitude: Double,
    longitude: Double
  ) -> Date? {

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    guard let year = components.year, let month = components.month, let day = components.day else {
      return nil
    }

    return sunset(
      year,
      month,
      day,
      latitude,
      longitude
    )
  }
}
