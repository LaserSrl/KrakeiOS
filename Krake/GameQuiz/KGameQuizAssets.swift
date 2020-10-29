// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "KGameQuizImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias KGameQuizAssetImageTypeAlias = KGameQuizImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum KGameQuizAssets {
  public static let background = KGameQuizImageAsset(name: "background")
  public static let correct = KGameQuizImageAsset(name: "correct")
  public static let gameCenter = KGameQuizImageAsset(name: "game_center")
  public static let icAccessTime = KGameQuizImageAsset(name: "ic_access_time")
  public static let icAlarm = KGameQuizImageAsset(name: "ic_alarm")
  public static let icClose = KGameQuizImageAsset(name: "ic_close")
  public static let icStarBorder = KGameQuizImageAsset(name: "ic_star_border")
  public static let star = KGameQuizImageAsset(name: "star")
  public static let wrong = KGameQuizImageAsset(name: "wrong")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct KGameQuizImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension KGameQuizImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the KGameQuizImageAsset.image property")
  convenience init?(asset: KGameQuizImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(url: Bundle.main.url(forResource: "GameQuiz", withExtension: "bundle")!)!
    #endif
  }()
}
// swiftlint:enable convenience_type
