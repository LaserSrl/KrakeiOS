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
@available(*, deprecated, renamed: "KImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = KImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum KAssets {
  public enum Images {
    public static let commercialUse = KImageAsset(name: "CommercialUse")
    public static let policy = KImageAsset(name: "Policy")
    public static let regulation = KImageAsset(name: "Regulation")
    public static let thirdParty = KImageAsset(name: "ThirdParty")
    public static let angry = KImageAsset(name: "angry")
    public static let angrySel = KImageAsset(name: "angry_sel")
    public static let boring = KImageAsset(name: "boring")
    public static let boringSel = KImageAsset(name: "boring_sel")
    public static let curious = KImageAsset(name: "curious")
    public static let curiousSel = KImageAsset(name: "curious_sel")
    public static let excited = KImageAsset(name: "excited")
    public static let excitedSel = KImageAsset(name: "excited_sel")
    public static let exhausted = KImageAsset(name: "exhausted")
    public static let exhaustedSel = KImageAsset(name: "exhausted_sel")
    public static let happy = KImageAsset(name: "happy")
    public static let happySel = KImageAsset(name: "happy_sel")
    public static let interested = KImageAsset(name: "interested")
    public static let interestedSel = KImageAsset(name: "interested_sel")
    public static let joke = KImageAsset(name: "joke")
    public static let jokeSel = KImageAsset(name: "joke_sel")
    public static let kiss = KImageAsset(name: "kiss")
    public static let kissSel = KImageAsset(name: "kiss_sel")
    public static let like = KImageAsset(name: "like")
    public static let likeSel = KImageAsset(name: "like_sel")
    public static let love = KImageAsset(name: "love")
    public static let loveSel = KImageAsset(name: "love_sel")
    public static let normal = KImageAsset(name: "normal")
    public static let normalSel = KImageAsset(name: "normal_sel")
    public static let pain = KImageAsset(name: "pain")
    public static let painSel = KImageAsset(name: "pain_sel")
    public static let sad = KImageAsset(name: "sad")
    public static let sadSel = KImageAsset(name: "sad_sel")
    public static let shocked = KImageAsset(name: "shocked")
    public static let shockedSel = KImageAsset(name: "shocked_sel")
    public static let silent = KImageAsset(name: "silent")
    public static let silentSel = KImageAsset(name: "silent_sel")
    public static let iwasthere = KImageAsset(name: "iwasthere")
    public static let iwasthereSel = KImageAsset(name: "iwasthere_sel")
    public static let addAlarm = KImageAsset(name: "add_alarm")
    public static let addCart = KImageAsset(name: "add_cart")
    public static let back = KImageAsset(name: "back")
    public static let calendar = KImageAsset(name: "calendar")
    public static let cart = KImageAsset(name: "cart")
    public static let bigCluster = KImageAsset(name: "bigCluster")
    public static let mediumCluster = KImageAsset(name: "medium-cluster")
    public static let smallCluster = KImageAsset(name: "small-cluster")
    public static let delete = KImageAsset(name: "delete")
    public static let email = KImageAsset(name: "email")
    public static let error = KImageAsset(name: "error")
    public static let google = KImageAsset(name: "google")
    public static let facebookLogin = KImageAsset(name: "facebook_login")
    public static let facebookLong = KImageAsset(name: "facebook_long")
    public static let linkedinCircle = KImageAsset(name: "linkedin_circle")
    public static let twitterLogin = KImageAsset(name: "twitter_login")
    public static let logout = KImageAsset(name: "logout")
    public static let oClist = KImageAsset(name: "OClist")
    public static let oCmap = KImageAsset(name: "OCmap")
    public static let oCnavigaverso = KImageAsset(name: "OCnavigaverso")
    public static let oCsatellite = KImageAsset(name: "OCsatellite")
    public static let oCstreet = KImageAsset(name: "OCstreet")
    public static let oCturnbyturn = KImageAsset(name: "OCturnbyturn")
    public static let pinPartenza = KImageAsset(name: "pin_partenza")
    public static let pinPos = KImageAsset(name: "pin_pos")
    public static let pinTraguardo = KImageAsset(name: "pin_traguardo")
    public static let zoomOutMap = KImageAsset(name: "zoom_out_map")
    public static let icCamera = KImageAsset(name: "ic_camera")
    public static let icMic = KImageAsset(name: "ic_mic")
    public static let icVideocam = KImageAsset(name: "ic_videocam")
    public static let more = KImageAsset(name: "more")
    public static let pdfIcon = KImageAsset(name: "pdf_icon")
    public static let person = KImageAsset(name: "person")
    public static let phone = KImageAsset(name: "phone")
    public static let removeAlarm = KImageAsset(name: "remove_alarm")
    public static let removeCart = KImageAsset(name: "remove_cart")
    public static let scrollTop = KImageAsset(name: "scroll_top")
    public static let search = KImageAsset(name: "search")
    public static let send = KImageAsset(name: "send")
    public static let settings = KImageAsset(name: "settings")
    public static let shareIcon = KImageAsset(name: "share_icon")
    public static let facebook = KImageAsset(name: "facebook")
    public static let googleCircle = KImageAsset(name: "google_circle")
    public static let instagram = KImageAsset(name: "instagram")
    public static let pinterest = KImageAsset(name: "pinterest")
    public static let twitter = KImageAsset(name: "twitter")
    public static let twitterCircle = KImageAsset(name: "twitter_circle")
    public static let twitterLogo = KImageAsset(name: "twitter_logo")
    public static let whatsApp = KImageAsset(name: "whatsApp")
    public static let youtube = KImageAsset(name: "youtube")
    public static let success = KImageAsset(name: "success")
    public static let termiconAll = KImageAsset(name: "termicon_all")
    public static let ticket = KImageAsset(name: "ticket")
    public static let watchLater = KImageAsset(name: "watch_later")
    public static let web = KImageAsset(name: "web")
  }
  public enum OrchardMapper {
    public static let close = KImageAsset(name: "close")
    public static let icAdd = KImageAsset(name: "ic_add")
    public static let indietro = KImageAsset(name: "indietro")
    public static let license = KImageAsset(name: "license")
    public static let audioPlaceholder = KImageAsset(name: "audio_placeholder")
    public static let defaultPlaceholder = KImageAsset(name: "default_placeholder")
    public static let photoPlaceholder = KImageAsset(name: "photo_placeholder")
    public static let userPlaceholder = KImageAsset(name: "user_placeholder")
    public static let videoPlaceholder = KImageAsset(name: "video_placeholder")
    public static let scrollBottom = KImageAsset(name: "scroll_bottom")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct KImageAsset {
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

public extension KImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the KImageAsset.image property")
  convenience init?(asset: KImageAsset) {
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
    return Bundle(url: Bundle.main.url(forResource: "KrakeImages", withExtension: "bundle")!)!
    #endif
  }()
}
// swiftlint:enable convenience_type
