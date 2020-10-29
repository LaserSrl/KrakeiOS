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
@available(*, deprecated, renamed: "KOTPImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias KOTPAssetImageTypeAlias = KOTPImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum KOTPAssets {
  public static let pinBus = KOTPImageAsset(name: "pin_bus")
  public static let pinMetro = KOTPImageAsset(name: "pin_metro")
  public static let pinMezzoGenerico = KOTPImageAsset(name: "pin_mezzo_generico")
  public static let pinTram = KOTPImageAsset(name: "pin_tram")
  public static let arrowUp = KOTPImageAsset(name: "arrow_up")
  public static let busStop = KOTPImageAsset(name: "bus_stop")
  public static let dateForward = KOTPImageAsset(name: "date_forward")
  public static let datePrevious = KOTPImageAsset(name: "date_previous")
  public static let durata = KOTPImageAsset(name: "durata")
  public static let fermate = KOTPImageAsset(name: "fermate")
  public static let icArrowBack = KOTPImageAsset(name: "ic_arrow_back")
  public static let icDirectionsBike = KOTPImageAsset(name: "ic_directions_bike")
  public static let icDirectionsCar = KOTPImageAsset(name: "ic_directions_car")
  public static let icDirectionsTransit = KOTPImageAsset(name: "ic_directions_transit")
  public static let icDirectionsWalk = KOTPImageAsset(name: "ic_directions_walk")
  public static let icPlanDate = KOTPImageAsset(name: "ic_plan_date")
  public static let continuaDritto = KOTPImageAsset(name: "continua_dritto")
  public static let destra45 = KOTPImageAsset(name: "destra_45")
  public static let destra90 = KOTPImageAsset(name: "destra_90")
  public static let inversioneUDx = KOTPImageAsset(name: "inversione_u_dx")
  public static let inversioneUSx = KOTPImageAsset(name: "inversione_u_sx")
  public static let rotonda = KOTPImageAsset(name: "rotonda")
  public static let sinistra45 = KOTPImageAsset(name: "sinistra_45")
  public static let sinistra90 = KOTPImageAsset(name: "sinistra_90")
  public static let muoversi = KOTPImageAsset(name: "muoversi")
  public static let pagaSosta = KOTPImageAsset(name: "paga_sosta")
  public static let parckingLogo = KOTPImageAsset(name: "parcking_logo")
  public static let steps = KOTPImageAsset(name: "steps")
  public static let viaggiaApiedi = KOTPImageAsset(name: "viaggia_apiedi")
  public static let viaggiaAuto = KOTPImageAsset(name: "viaggia_auto")
  public static let viaggiaBici = KOTPImageAsset(name: "viaggia_bici")
  public static let viaggiaBus = KOTPImageAsset(name: "viaggia_bus")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct KOTPImageAsset {
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

public extension KOTPImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the KOTPImageAsset.image property")
  convenience init?(asset: KOTPImageAsset) {
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
    return Bundle(url: Bundle.main.url(forResource: "OTP", withExtension: "bundle")!)!
    #endif
  }()
}
// swiftlint:enable convenience_type
