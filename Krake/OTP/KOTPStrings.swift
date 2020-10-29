// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum KOTPLocalization {
  /// Arrivo
  public static let arrivo = KOTPLocalization.tr("KOTPLocalizable", "Arrivo")
  /// In bus
  public static let bus = KOTPLocalization.tr("KOTPLocalizable", "BUS")
  ///  per 
  public static let by = KOTPLocalization.tr("KOTPLocalizable", "BY")
  /// Cambi
  public static let cambi = KOTPLocalization.tr("KOTPLocalizable", "Cambi")
  /// in direzione
  public static let directionBy = KOTPLocalization.tr("KOTPLocalizable", "direction_by")
  /// Trascina per spostare
  public static let dragToMove = KOTPLocalization.tr("KOTPLocalizable", "Drag to move")
  /// Durata
  public static let durata = KOTPLocalization.tr("KOTPLocalizable", "Durata")
  /// Percorso più veloce
  public static let fastTrip = KOTPLocalization.tr("KOTPLocalizable", "fastTrip")
  /// Da
  public static let from = KOTPLocalization.tr("KOTPLocalizable", "from")
  /// ore %@
  public static func hour(_ p1: Any) -> String {
    return KOTPLocalization.tr("KOTPLocalizable", "hour", String(describing: p1))
  }
  /// (Fine corsa)
  public static let lastStop = KOTPLocalization.tr("KOTPLocalizable", "lastStop")
  /// Linea %@ - %@ %@
  public static func lineTo(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return KOTPLocalization.tr("KOTPLocalizable", "lineTo", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Posizione
  public static let location = KOTPLocalization.tr("KOTPLocalizable", "location")
  /// %@ minuti
  public static func minutes(_ p1: Any) -> String {
    return KOTPLocalization.tr("KOTPLocalizable", "minutes", String(describing: p1))
  }
  /// La mia posizione
  public static let myLocation = KOTPLocalization.tr("KOTPLocalizable", "myLocation")
  /// No
  public static let no = KOTPLocalization.tr("KOTPLocalizable", "no")
  /// Ok
  public static let ok = KOTPLocalization.tr("KOTPLocalizable", "ok")
  /// in arrivo
  public static let onMyWay = KOTPLocalization.tr("KOTPLocalizable", "onMyWay")
  /// Partenza
  public static let partenza = KOTPLocalization.tr("KOTPLocalizable", "Partenza")
  /// Percorso a piedi
  public static let percorsoAPiedi = KOTPLocalization.tr("KOTPLocalizable", "Percorso a piedi")
  /// ATTENDERE PREGO
  public static let pleaseWaiting = KOTPLocalization.tr("KOTPLocalizable", "please_waiting")
  /// Impostazioni
  public static let settings = KOTPLocalization.tr("KOTPLocalizable", "settings")
  /// Fermata
  public static let stop = KOTPLocalization.tr("KOTPLocalizable", "stop")
  /// Ricerca fermate
  public static let stopSearch = KOTPLocalization.tr("KOTPLocalizable", "stopSearch")
  /// Metro
  public static let subway = KOTPLocalization.tr("KOTPLocalizable", "SUBWAY")
  /// A
  public static let to = KOTPLocalization.tr("KOTPLocalizable", "to")
  /// In tram
  public static let tram = KOTPLocalization.tr("KOTPLocalizable", "TRAM")
  /// Stiamo calcolando il percorso
  public static let tripRoute = KOTPLocalization.tr("KOTPLocalizable", "trip_route")
  /// Si
  public static let yes = KOTPLocalization.tr("KOTPLocalizable", "yes")

  public enum Alert {
    /// Non vi sono fermate nei pressi della zona evidenziata
    public static let canNotFindStops = KOTPLocalization.tr("KOTPLocalizable", "Alert.CAN_NOT_FIND_STOPS")
    /// Non è stato possibile caricare l'itinerario
    public static let canNotTrip = KOTPLocalization.tr("KOTPLocalizable", "Alert.CAN_NOT_TRIP")
    /// Disattiva le notifiche per tutte le fermate.
    public static let disableAllStopsNotification = KOTPLocalization.tr("KOTPLocalizable", "Alert.DISABLE_ALL_STOPS_NOTIFICATION")
    /// Vuoi disabilitare tutte le notifiche?
    public static let disableAllStopsNotificationQuestion = KOTPLocalization.tr("KOTPLocalizable", "Alert.DISABLE_ALL_STOPS_NOTIFICATION_QUESTION")
    /// Vuoi disabilitare la notifica?
    public static let disableStopNotificationQuestion = KOTPLocalization.tr("KOTPLocalizable", "Alert.DISABLE_STOP_NOTIFICATION_QUESTION")
    /// Vuoi essere notificato quando sei nei paraggi della fermata?
    public static let enableStopNotificationQuestion = KOTPLocalization.tr("KOTPLocalizable", "Alert.ENABLE_STOP_NOTIFICATION_QUESTION")
    /// Cerca fermate vicino a
    public static let findStopsNearby = KOTPLocalization.tr("KOTPLocalizable", "Alert.FIND_STOPS_NEARBY")
    /// Abilita sempre la localizzazione per usufruire della funzionalità.
    public static let localizationError = KOTPLocalization.tr("KOTPLocalizable", "Alert.LOCALIZATION_ERROR")
    /// Attenzione: puoi attivare un massimo di 20 fermate; prima di procedere con l'attivazione di una nuova fermata, devi disabilitarne un'altra.
    public static let maxNumberOfRegion = KOTPLocalization.tr("KOTPLocalizable", "Alert.MAX_NUMBER_OF_REGION")
    /// Stai per arrivare alla fermata '%@'
    public static func stopNotification(_ p1: Any) -> String {
      return KOTPLocalization.tr("KOTPLocalizable", "Alert.STOP_NOTIFICATION", String(describing: p1))
    }
  }

  public enum DirectionDescription {
    /// Dopo %s
    public static func after(_ p1: UnsafePointer<CChar>) -> String {
      return KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.after", p1)
    }
    /// Alla rotonda prendi la %@ uscita
    public static func circle(_ p1: Any) -> String {
      return KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.circle", String(describing: p1))
    }
    /// Continua
    public static let `continue` = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.continue")
    /// Parti
    public static let depart = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.depart")
    /// Gira a sinistra
    public static let hardLeft = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.hardLeft")
    /// Gira a destra
    public static let hardRight = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.hardRight")
    /// Svolta a sinistra
    public static let `left` = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.left")
    /// Svolta a destra
    public static let `right` = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.right")
    /// Gira lievemente a sinistra
    public static let slightlyLeft = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.slightlyLeft")
    /// Gira lievemente a destra
    public static let slightlyRight = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.slightlyRight")
    /// Fai inversione a U
    public static let uturn = KOTPLocalization.tr("KOTPLocalizable", "DirectionDescription.uturn")
  }

  public enum Error {
    /// Errore generico
    public static let generic = KOTPLocalization.tr("KOTPLocalizable", "Error.generic")
  }

  public enum Stop {
    /// Nome della fermata
    public static let name = KOTPLocalization.tr("KOTPLocalizable", "Stop.name")
  }

  public enum TravelMode {
    /// Vai in bici fino a 
    public static let bicycle = KOTPLocalization.tr("KOTPLocalizable", "TravelMode.bicycle")
    /// Guida fino a
    public static let car = KOTPLocalization.tr("KOTPLocalizable", "TravelMode.car")
    /// Cammina per
    public static let walk = KOTPLocalization.tr("KOTPLocalizable", "TravelMode.walk")
  }

  public enum TripIsNotPossible {
    /// Non è stato possibile calcolare il tragitto richiesto in quanto è fuori dall'area prevista.
    public static let youMightBeTryingToPlanATripOutsideTheMapDataBoundary = KOTPLocalization.tr("KOTPLocalizable", "Trip is not possible.  You might be trying to plan a trip outside the map data boundary.")
  }

  public enum TripMode {
    /// Arrivo entro
    public static let arrivo = KOTPLocalization.tr("KOTPLocalizable", "TripMode.arrivo")
    /// Partenza
    public static let partenza = KOTPLocalization.tr("KOTPLocalizable", "TripMode.partenza")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension KOTPLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
  public static func localizable(_ key: String, checkInApp: Bool = false, _ args: CVarArg...) -> String {
    if checkInApp {
      return Bundle.main.localizedString(forKey: key, value: tr("KOTPLocalizable", key, args), table: nil)
    } else {
      return tr("KOTPLocalizable", key, args)
    }
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
