import Foundation

extension SunriseSunsetProvider {

  /// Uses an algorithm developed by Paul Schlyter to calculate sunrise and sunset.
  ///
  /// The bulk of the code driving this functionality can be found in the ``Schlyter`` enum. That file contains a conversion of Schlyter's original C code into Swift.
  ///
  /// A study published by the American Astronomical Society ([link](https://ui.adsabs.harvard.edu/abs/2018AAS...23115003P/abstract)) reports that this algorithm diverges from other algorithms as location gets closer to the poles, and it has potential to incorrectly classify edge cases.
  ///
  /// Anecdotally, this algorithm seems to perform pretty well for several use cases for apps in the Apple ecosystem.
  ///
  /// Schlyter made the algorithm available for the Public Domain.
  /// * [Link to the algorithm in C](http://www.stjarnhimlen.se/comp/sunriset.c).
  public static var schlyter: Self {
    .init(
      sunrise: { year, month, day, latitude, longitude in

        // Rise is returned as hours (UTC) from the start of the day.
        let (rise, _, returnCode) = Schlyter.sunRiseSet(
          year: year,
          month: month,
          day: day,
          lon: longitude,
          lat: latitude
        )

        // If the return code is not 0, there is no true sunrise for this location.
        guard returnCode == 0 else { return nil }

        let date = Calendar.gmtGregorian?.date(
          from: .init(
            year: year,
            month: month,
            day: day
          )
        )

        let sunriseSecondsFromStartOfDay = rise * 3600

        return date?.addingTimeInterval(sunriseSecondsFromStartOfDay)
      },
      sunset: { year, month, day, latitude, longitude in

        // Set is returned as hours (UTC) from the start of the day.
        let (_, set, returnCode) = Schlyter.sunRiseSet(
          year: year,
          month: month,
          day: day,
          lon: longitude,
          lat: latitude
        )

        // If the return code is not 0, there is no true sunset for this location.
        guard returnCode == 0 else { return nil }

        let date = Calendar.gmtGregorian?.date(
          from: .init(
            year: year,
            month: month,
            day: day
          )
        )

        let sunsetSecondsFromStartOfDay = set * 3600

        return date?.addingTimeInterval(sunsetSecondsFromStartOfDay)
      }
    )
  }
}
