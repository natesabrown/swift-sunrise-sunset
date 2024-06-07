import Foundation

/// A translation of the logic from Paul Schlyter's [sunriset.c](http://www.stjarnhimlen.se/comp/sunriset.c) C code to Swift.
///
/// ## Translation Philosophy
/// The aim is to make minimal embellishments to the original C code's structure and logic, while introducing Swift-style syntax and naming conventions.
/// * Comments are converted to Swift `//` or `///` comments.
/// * Macros are converted to functions and given parameter and return types.
/// * Function and variable names are rewritten in camel case.
/// * `Double.pi` is used instead of a locally-defined constant for pi.
/// * Certain typos in comments are fixed. Additionally, C-specific references have been altered to be more general (e.g., "C compiler" turns into "compiler").
enum Schlyter {

  /// Computes the number of days elapsed since 2000 Jan 0.0
  /// (which is equal to 1999 Dec 31, 0h UT)
  static func daysSince2000Jan0(year: Int, month: Int, day: Int) -> Int {
    (367 * year - ((7 * (year + ((month + 9) / 12))) / 4) + ((275 * month) / 9) + day - 730530)
  }

  // Some conversion factors between radians and degrees
  static var radDeg: Double { 180 / .pi }
  static var degRad: Double { .pi / 180 }

  // The trigonometric functions in degrees
  static func sind(_ x: Double) -> Double { sin(x * degRad) }
  static func cosd(_ x: Double) -> Double { cos(x * degRad) }
  static func tand(_ x: Double) -> Double { tan(x * degRad) }

  static func atand(_ x: Double) -> Double { radDeg * atan(x) }
  static func asind(_ x: Double) -> Double { radDeg * asin(x) }
  static func acosd(_ x: Double) -> Double { radDeg * acos(x) }
  static func atan2d(_ y: Double, _ x: Double) -> Double { radDeg * atan2(y, x) }

  // Following are some functions around the "workhorse" function `_daylen`.
  // They mainly fill in the desired values for the reference altitude
  // below the horizon, and also selects whether this altitude should
  // refer to the Sun's center or its upper limb.

  /// Computes the length of the day, from sunrise to sunset.
  /// Sunrise/set is considered to occur when the Sun's upper limb is
  /// 35 arc minutes below the horizon (this accounts for the refraction
  /// of the Earth's atmosphere).
  static func dayLength(year: Int, month: Int, day: Int, lon: Double, lat: Double) -> Double {
    _daylen(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -35.0 / 60.0,
      upperLimb: 1
    )
  }

  /// Computes the length of the day, including civil twilight.
  /// Civil twilight starts/ends when the Sun's center is 6 degrees below
  /// the horizon.
  static func dayCivilTwilightLength(year: Int, month: Int, day: Int, lon: Double, lat: Double)
    -> Double
  {
    _daylen(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -6.0,
      upperLimb: 0
    )
  }

  /// Computes the length of the day, incl. nautical twilight.
  /// Nautical twilight starts/ends when the Sun's center is 12 degrees
  /// below the horizon.
  static func dayNauticalTwilightLength(year: Int, month: Int, day: Int, lon: Double, lat: Double)
    -> Double
  {
    _daylen(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -12.0,
      upperLimb: 0
    )
  }

  /// Computes the length of the day, incl. astronomical twilight.
  /// Astronomical twilight starts/ends when the Sun's center is 18 degrees
  /// below the horizon.
  static func dayAstronomicalTwilightLength(
    year: Int, month: Int, day: Int, lon: Double, lat: Double
  )
    -> Double
  {
    _daylen(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -18.0,
      upperLimb: 0
    )
  }

  /// Computes times for sunrise/sunset.
  /// Sunrise/set is considered to occur when the Sun's upper limb is
  /// 35 arc minutes below the horizon (this accounts for the refraction
  /// of the Earth's atmosphere).
  static func sunRiseSet(year: Int, month: Int, day: Int, lon: Double, lat: Double) -> (
    rise: Double, set: Double, returnCode: Int
  ) {
    _sunriset(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -35.0 / 60.0,
      upperLimb: 1
    ) as (Double, Double, Int)
  }

  /// Computes the start and end times of civil twilight.
  /// Civil twilight starts/ends when the Sun's center is 6 degrees below
  /// the horizon.
  static func civilTwilight(year: Int, month: Int, day: Int, lon: Double, lat: Double) -> (
    rise: Double, set: Double, returnCode: Int
  ) {
    _sunriset(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -6.0,
      upperLimb: 0
    ) as (Double, Double, Int)
  }

  /// Computes the start and end times of nautical twilight.
  /// Nautical twilight starts/ends when the Sun's center is 12 degrees
  /// below the horizon.
  static func nauticalTwilight(year: Int, month: Int, day: Int, lon: Double, lat: Double) -> (
    rise: Double, set: Double, returnCode: Int
  ) {
    _sunriset(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -12.0,
      upperLimb: 0
    ) as (Double, Double, Int)
  }

  /// Computes the start and end times of astronomical twilight.
  /// Astronomical twilight starts/ends when the Sun's center is 18 degrees
  /// below the horizon.
  static func astronomicalTwilight(year: Int, month: Int, day: Int, lon: Double, lat: Double) -> (
    rise: Double, set: Double, returnCode: Int
  ) {
    _sunriset(
      year: year,
      month: month,
      day: day,
      lon: lon,
      lat: lat,
      altit: -18.0,
      upperLimb: 0
    ) as (Double, Double, Int)
  }

  /// The "workhorse" function for sun rise/set times.
  ///
  /// Note: year, month, date = calendar date, 1801–2099 only.
  ///
  /// * Eastern longitude positive, Western longitude negative.
  /// * Northern latitude positive, Southern latitude negative.
  /// * The longitude value _is_ critical in this function!
  /// * `altit`: The altitude which the Sun should cross.
  /// Set to `-35/60` degrees for rise/set, `-6` degrees for civil, `-12` degrees for nautical and `-18` degrees for astronomical twilight.
  /// * `upperLimb`: Non-zero -> upper limb, zero -> center.
  /// Set to non-zero (e.g. `1`) when computing rise/set times, and to `0` when computing start/end of twilight.
  ///
  /// Both return times are relative to the specified altitude, and thus this function can be used to compute various twilight times, as well as rise/set times.
  ///
  /// Return value:
  /// * `0`: Sun rises/sets this day, times returned as `tRise` and `tSet`.
  /// * `1`: Sun above the specified "horizon" 24 hours. `tRise` returned as the time when the sun is at south, minus 12 hours while `tSet` is set to the south time plus 12 hours. "Day" length = 24 hours.
  /// * `-1`: Sun is below the specified "horizon" 24 hours. "Day" length = 0 hours, `tRise` and `tSet` are both returned as the time when the sun is at south.
  static func _sunriset(
    year: Int,
    month: Int,
    day: Int,
    lon: Double,
    lat: Double,
    altit: Double,
    upperLimb: Int
  ) -> (tRise: Double, tSet: Double, rc: Int) {

    var altit = altit

    /// Days since 2000 Jan 0.0 (negative before)
    var d: Double
    /// Solar distance, astronomical units
    var sr: Double
    /// Sun's Right Ascension
    var sRA: Double
    /// Sun's declination
    var sDec: Double
    /// Sun's apparent radius
    var sRadius: Double
    /// Diurnal arc
    var t: Double
    /// Time when Sun is at south
    var tSouth: Double
    /// Local sidereal time
    var sidTime: Double

    /// Return code from the function - usually 0
    var rc = 0

    // Compute d of 12h local mean solar time
    d = Double(daysSince2000Jan0(year: year, month: month, day: day)) + 0.5 - lon / 360.0

    // Compute the local sidereal time of this moment
    sidTime = revolution(GMST0(d) + 180.0 + lon)

    // Compute Sun's RA, Decl and distance at this moment
    (sRA, sDec, sr) = sunRaDec(d: d)

    // Compute time when Sun is at south - in hours UT
    tSouth = 12.0 - rev180(sidTime - sRA) / 15.0

    // Compute the Sun's apparent radius in degrees
    sRadius = 0.2666 / sr

    // Do correction to upper limb, if necessary
    if upperLimb != 0 {
      altit -= sRadius
    }

    // Compute the diurnal arc that the Sun traverses to reach
    // the specified altitude altit
    var cost: Double
    cost = (sind(altit) - sind(lat) * sind(sDec)) / (cosd(lat) * cosd(sDec))
    if cost >= 1.0 {
      // Sun always below altit
      rc = -1
      t = 0
    } else if cost <= -1.0 {
      // Sun always above altit
      rc = 1
      t = 12
    } else {
      // The diurnal arc, hours
      t = acosd(cost) / 15.0
    }

    // Return rise and set times in hours UT
    let tRise = tSouth - t
    let tSet = tSouth + t

    return (tRise, tSet, rc)
  }

  /// The "workhorse" function.
  ///
  /// Note: year, month, date = calendar date, 1801–2099 only.
  ///
  /// * Eastern longitude positive, Western longitude negative.
  /// * Northern latitude positive, Southern latitude negative.
  /// * The longitude value is not critical. Set it to the correct longitude if you're picky, otherwise set to to, say, `0.0`.
  /// * The latitude however _is_ critical - be sure to get it correct.
  /// * `altit`: The altitude which the Sun should cross.
  /// Set to `-35/60` degrees for rise/set, `-6` degrees for civil, `-12` degrees for nautical and `-18` degrees for astronomical twilight.
  /// * `upper_limb`: Non-zero -> upper limb, zero -> center.
  /// Set to non-zero (e.g. `1`) when computing day length and to `0` when computing day + twilight length.
  static func _daylen(
    year: Int,
    month: Int,
    day: Int,
    lon: Double,
    lat: Double,
    altit: Double,
    upperLimb: Int
  ) -> Double {

    var altit = altit

    /// Days since 2000 Jan 0.0 (negative before)
    var d: Double
    /// Obliquity (inclination) of Earth's axis
    var oblEcl: Double
    /// Solar distance, astronomical units
    var sr: Double
    /// True solar longitude
    var sLon: Double
    /// Sine of Sun's declination
    var sinSDecl: Double
    /// Cosine of the Sun's declination
    var cosSDecl: Double
    /// Sun's apparent radius
    var sRadius: Double
    /// Diurnal arc
    var t: Double

    // Compute d of 12h local mean solar time
    d = Double(daysSince2000Jan0(year: year, month: month, day: day)) + 0.5 - lon / 360.0

    // Compute obliquity of ecliptic (inclination of Earth's axis)
    oblEcl = 23.4393 - 3.563E-7 * d

    // Compute Sun's ecliptic longitude and distance
    (sLon, sr) = sunPos(d: d)

    // Compute sine and cosine of Sun's declination
    sinSDecl = sind(oblEcl) * sind(sLon)
    cosSDecl = sqrt(1.0 - sinSDecl * sinSDecl)

    // Compute the Sun's apparent radius, degrees
    sRadius = 0.2666 / sr

    // Do correction to upper limb, if necessary
    if upperLimb != 0 {
      altit -= sRadius
    }

    // Compute the diurnal arc that the Sun traverses to reach
    // the specified altitude altit
    var cost: Double
    cost = (sind(altit) - sind(lat) * sinSDecl) / (cosd(lat) * cosSDecl)
    if cost >= 1.0 {
      // Sun always below altit
      t = 0
    } else if cost <= -1.0 {
      // Sun always above altit
      t = 24
    } else {
      // The diurnal arc, hours
      t = (2.0 / 15.0) * acosd(cost)
    }
    return t
  }

  /// Computes the Sun's ecliptic longitude and distance
  /// at an instant given in d, number of days since
  /// 2000 Jan 0.0.  The Sun's ecliptic latitude is not
  /// computed, since it's always very near 0.
  static func sunPos(
    d: Double
  ) -> (lon: Double, r: Double) {
    /// Mean anomaly of the Sun
    var M: Double
    /// Mean longitude of the perihelion.
    /// Note: Sun's mean longitude = M + w
    var w: Double
    /// Eccentricity of the Earth's orbit
    var e: Double
    /// Eccentric anomaly
    var E: Double
    // x, y coordinates in orbit.
    var x: Double
    var y: Double
    /// True anomaly.
    var v: Double

    // Compute mean elements
    M = revolution(356.0470 + 0.9856002585 * d)
    w = 282.9404 + 4.70935E-5 * d
    e = 0.016709 - 1.151E-9 * d

    // Compute true longitude and radius vector
    E = M + e * radDeg * sind(M) * (1.0 + e * cosd(M))
    x = cosd(E) - e
    y = sqrt(1.0 - e * e) * sind(E)
    // Solar distance
    let r = sqrt(x * x + y * y)
    // True anomaly
    v = atan2d(y, x)
    // True solar longitude
    var lon = v + w
    if lon >= 360.0 {
      // Make it 0..360 degrees
      lon -= 360.0
    }

    return (lon, r)
  }

  /// Computes the Sun's equatorial coordinates RA, Decl
  /// and also its distance, at an instant given in d,
  /// the number of days since 2000 Jan 0.0.
  static func sunRaDec(
    d: Double
  ) -> (RA: Double, dec: Double, r: Double) {

    var obl_ecl: Double
    var x: Double
    var y: Double
    var z: Double

    // Compute Sun's ecliptical coordinates
    let (lon, r) = sunPos(d: d)

    // Compute ecliptic rectangular coordinates (z=0)
    x = r * cosd(lon)
    y = r * sind(lon)

    // Compute obliquity of ecliptic (inclination of Earth's axis)
    obl_ecl = 23.4393 - 3.563E-7 * d

    // Convert to equatorial rectangular coordinates - x is unchanged
    z = y * sind(obl_ecl)
    y = y * cosd(obl_ecl)

    // Convert to spherical coordinates
    let RA = atan2d(y, x)
    let dec = atan2d(z, sqrt(x * x + y * y))

    return (RA, dec, r)
  }

  static var INV360: Double { 1.0 / 360.0 }

  /// Reduce angle to within 0..360 degrees.
  static func revolution(_ x: Double) -> Double {
    x - 360.0 * floor(x * INV360)
  }

  /// Reduce angle to within +180..+180 degrees.
  static func rev180(_ x: Double) -> Double {
    x - 360.0 * floor(x * INV360 + 0.5)
  }

  /// This function computes GMST0, the Greenwich Mean Sidereal Time
  /// at 0h UT (i.e. the sidereal time at the Greenwhich meridian at
  /// 0h UT).  GMST is then the sidereal time at Greenwich at any
  /// time of the day.
  ///
  /// I've generalized GMST0 as well, and define it
  /// as:  GMST0 = GMST - UT  --  this allows GMST0 to be computed at
  /// other times than 0h UT as well.  While this sounds somewhat
  /// contradictory, it is very practical:  instead of computing
  /// GMST like:
  ///
  /// ```
  /// GMST = (GMST0) + UT * (366.2422/365.2422)
  /// ```
  ///
  /// where (GMST0) is the GMST last time UT was 0 hours, one simply
  /// computes:
  ///
  /// ```
  /// GMST = GMST0 + UT
  /// ```
  ///
  /// where GMST0 is the GMST "at 0h UT" but at the current moment!
  /// Defined in this way, GMST0 will increase with about 4 min a
  /// day.  It also happens that GMST0 (in degrees, 1 hr = 15 degr)
  /// is equal to the Sun's mean longitude plus/minus 180 degrees!
  /// (If we neglect aberration, which amounts to 20 seconds of arc
  /// or 1.33 seconds of time.)
  static func GMST0(_ d: Double) -> Double {
    // Sidtime at 0h UT = L (Sun's mean longitude) + 180.0 degr
    // L = M + w, as defined in sunpos(). Since I'm too lazy to
    // add these numbers, I'll let the compiler do it for me.
    // Any decent compiler will add the constants at compile
    // time, imposing no runtime or code overhead.
    revolution((180.0 + 356.0470 + 282.9404) + (0.9856002585 + 4.70935E-5) * d)
  }
}
