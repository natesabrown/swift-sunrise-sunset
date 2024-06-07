import Foundation

extension TimeZone {

  /// Backport `TimeZone.gmt` so this can be used in earlier OS versions.
  ///
  /// > Note: There is no difference between UTC and GMT in Swift, and it is a common convention to use GMT over UTC when one
  /// might be preferred. See [this StackOverflow discussion](https://stackoverflow.com/questions/58307194/swift-utc-timezone-is-not-utc).
  static var backportGmt: Self? {
    if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
      .gmt
    } else {
      .init(identifier: "GMT")
    }
  }
}
