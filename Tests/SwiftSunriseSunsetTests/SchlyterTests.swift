import CoreLocation
import SwiftSunriseSunset
import XCTest

final class SchlyterTests: XCTestCase {

  // MARK: - Test Sunrise
  func testSunrise() throws {

    let sunrise = try XCTUnwrap(
      SwiftSunriseSunset.sunrise(
        for: .summerSolstice2024,
        in: try .usPacific,
        at: .sanFrancisco
      )
    )

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
    formatter.timeZone = try .usPacific
    let expectedSunriseTime = try XCTUnwrap(formatter.date(from: "2024-06-20 05:48:01.3499"))

    XCTAssertEqual(
      sunrise.timeIntervalSince1970,
      expectedSunriseTime.timeIntervalSince1970,
      accuracy: 0.01
    )
  }

  func testSunriseNoSunriseAllDay() throws {

    let sunrise = SwiftSunriseSunset.sunrise(
      for: .summerSolstice2024,
      in: try .usPacific,
      at: .northPole
    )

    XCTAssertNil(sunrise)
  }

  func testSunriseNoSunriseAllNight() throws {

    let sunrise = SwiftSunriseSunset.sunrise(
      for: .summerSolstice2024,
      in: try .usPacific,
      at: .southPole
    )

    XCTAssertNil(sunrise)
  }

  // MARK: - Test Sunset
  func testSunset() throws {

    let sunset = try XCTUnwrap(
      SwiftSunriseSunset.sunset(
        for: .summerSolstice2024,
        in: try .usPacific,
        at: .sanFrancisco
      )
    )

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
    formatter.timeZone = try .usPacific
    let expectedSunriseTime = try XCTUnwrap(formatter.date(from: "2024-06-20 20:34:59.9602"))

    XCTAssertEqual(
      sunset.timeIntervalSince1970,
      expectedSunriseTime.timeIntervalSince1970,
      accuracy: 0.01
    )
  }

  func testSunsetNoSunsetAllDay() throws {

    let sunset = SwiftSunriseSunset.sunset(
      for: .summerSolstice2024,
      in: try .usPacific,
      at: .southPole
    )

    XCTAssertNil(sunset)
  }

  func testSunsetNoSunsetAllNight() throws {

    let sunset = SwiftSunriseSunset.sunset(
      for: .summerSolstice2024,
      in: try .usPacific,
      at: .northPole
    )

    XCTAssertNil(sunset)
  }
}

// MARK: - Helpers
extension CLLocationCoordinate2D {

  static var sanFrancisco: Self {
    .init(latitude: 37.773972, longitude: -122.431297)
  }

  static var northPole: Self {
    .init(latitude: 90, longitude: 0)
  }

  static var southPole: Self {
    .init(latitude: -90, longitude: 0)
  }
}

extension Date {

  static var summerSolstice2024: Self {
    .init(timeIntervalSince1970: 1_718_866_800)
  }
}

extension TimeZone {

  static var usPacific: Self {
    get throws {
      try XCTUnwrap(
        .init(identifier: "America/Los_Angeles")
      )
    }
  }
}
