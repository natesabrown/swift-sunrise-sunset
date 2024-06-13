import Foundation

public enum SwiftSunriseSunset {

  /// Returns the sunrise for a given location on a given day.
  /// - Parameters:
  ///   - algorithm: The algorithm to use for calculating the sunrise, as expressed by a ``SunriseSunsetProvider``.
  ///   - date: The `Date` to calculate the sunrise for.
  ///   - timeZone: The `TimeZone` the sunrise should be calculated for.
  ///   - latitude: The latitude for the location.
  ///   - longitude: The longitude for the location.
  /// - Returns: A `Date?` for the time of sunrise. If there is no valid sunrise, returns `nil`.
  public static func sunrise(
    algorithm: SunriseSunsetProvider = .schlyter,
    for date: Date,
    in timeZone: TimeZone,
    latitude: Double,
    longitude: Double
  ) -> Date? {
    algorithm.sunrise(
      on: date,
      in: timeZone,
      latitude: latitude,
      longitude: longitude
    )
  }

  /// Returns the sunset for a given location on a given day.
  /// - Parameters:
  ///   - algorithm: The algorithm to use for calculating the sunset, as expressed by a ``SunriseSunsetProvider``.
  ///   - date: The `Date` to calculate the sunset for.
  ///   - timeZone: The `TimeZone` the sunset should be calculated for.
  ///   - latitude: The latitude for the location.
  ///   - longitude: The longitude for the location.
  /// - Returns: A `Date?` for the time of sunset. If there is no valid sunset, returns `nil`.
  public static func sunset(
    algorithm: SunriseSunsetProvider = .schlyter,
    for date: Date,
    in timeZone: TimeZone,
    latitude: Double,
    longitude: Double
  ) -> Date? {
    algorithm.sunset(
      on: date,
      in: timeZone,
      latitude: latitude,
      longitude: longitude
    )
  }
}

#if canImport(CoreLocation)
  import CoreLocation

  extension SwiftSunriseSunset {

    /// Returns the sunrise for a given location on a given day.
    /// - Parameters:
    ///   - algorithm: The algorithm to use for calculating the sunrise, as expressed by a ``SunriseSunsetProvider``.
    ///   - date: The `Date` to calculate the sunrise for.
    ///   - timeZone: The `TimeZone` the sunrise should be calculated for.
    ///   - location: The location the sunrise should be calculated for.
    /// - Returns: A `Date?` for the time of sunrise. If there is no valid sunrise, returns `nil`.
    public static func sunrise(
      algorithm: SunriseSunsetProvider = .schlyter,
      for date: Date,
      in timeZone: TimeZone,
      at location: CLLocationCoordinate2D
    ) -> Date? {
      Self.sunrise(
        algorithm: algorithm,
        on: date,
        in: timeZone,
        latitude: location.latitude,
        longitude: location.longitude
      )
    }

    /// Returns the sunset for a given location on a given day.
    /// - Parameters:
    ///   - algorithm: The algorithm to use for calculating the sunset, as expressed by a ``SunriseSunsetProvider``.
    ///   - date: The `Date` to calculate the sunset for.
    ///   - timeZone: The `TimeZone` the sunset should be calculated for.
    ///   - location: The location the sunrise should be calculated for.
    /// - Returns: A `Date?` for the time of sunset. If there is no valid sunset, returns `nil`.
    public static func sunset(
      algorithm: SunriseSunsetProvider = .schlyter,
      for date: Date,
      in timeZone: TimeZone,
      at location: CLLocationCoordinate2D
    ) -> Date? {
      Self.sunset(
        algorithm: algorithm,
        on: date,
        in: timeZone,
        latitude: location.latitude,
        longitude: location.longitude
      )
    }
  }
#endif
