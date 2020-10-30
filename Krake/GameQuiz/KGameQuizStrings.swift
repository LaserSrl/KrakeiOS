// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum KGameQuizLocalization {
  /// Il gioco sarà disponibile dal
  public static let availableSoon = KGameQuizLocalization.tr("KGameQuizLocalizable", "available_soon")
  /// Bravo!
  public static let bravo = KGameQuizLocalization.tr("KGameQuizLocalizable", "bravo")
  /// Confermi di voler inviare il seguente numero?\n\n
  public static let checkYourNumber = KGameQuizLocalization.tr("KGameQuizLocalizable", "check_your_number")
  /// I tuoi punti sono stati salvati correttamente.
  public static let contestParticipate = KGameQuizLocalization.tr("KGameQuizLocalizable", "contest_participate")
  /// Continua
  public static let `continue` = KGameQuizLocalization.tr("KGameQuizLocalizable", "continue")
  /// Vuoi autenticarti adesso?
  public static let gameCenterLoginNow = KGameQuizLocalization.tr("KGameQuizLocalizable", "game_center_login_now")
  /// Game Center è richiesto per partecipare al quiz.
  public static let gameCenterRequest = KGameQuizLocalization.tr("KGameQuizLocalizable", "game_center_request")
  /// Non puoi partecipare perchè non hai effettuato l'accesso al GameCenter
  public static let gameCenterNotLoggedIn = KGameQuizLocalization.tr("KGameQuizLocalizable", "gameCenterNotLoggedIn")
  /// inserisci il tuo numero
  public static let insertPhoneNumber = KGameQuizLocalization.tr("KGameQuizLocalizable", "insert_phone_number")
  /// Abbandona
  public static let leave = KGameQuizLocalization.tr("KGameQuizLocalizable", "leave")
  /// Accedi
  public static let login = KGameQuizLocalization.tr("KGameQuizLocalizable", "login")
  /// No
  public static let no = KGameQuizLocalization.tr("KGameQuizLocalizable", "no")
  /// Ok
  public static let ok = KGameQuizLocalization.tr("KGameQuizLocalizable", "ok")
  /// Ops!
  public static let ops = KGameQuizLocalization.tr("KGameQuizLocalizable", "ops")
  /// Partecipa
  public static let partecipate = KGameQuizLocalization.tr("KGameQuizLocalizable", "partecipate")
  /// punti
  public static let punti = KGameQuizLocalization.tr("KGameQuizLocalizable", "punti")
  /// Sei pronto per continuare la partita?
  public static let ruReady = KGameQuizLocalization.tr("KGameQuizLocalizable", "r_u_ready")
  /// Sei pronto per iniziare la partita?
  public static let ready = KGameQuizLocalization.tr("KGameQuizLocalizable", "ready")
  /// Risposta corretta.
  public static let rispostaCorretta = KGameQuizLocalization.tr("KGameQuizLocalizable", "risposta_corretta")
  /// Risposta errata.
  public static let rispostaErrata = KGameQuizLocalization.tr("KGameQuizLocalizable", "risposta_errata")
  /// Numero non valido
  public static let smsNotValid = KGameQuizLocalization.tr("KGameQuizLocalizable", "sms_not_valid")
  /// Inizia
  public static let start = KGameQuizLocalization.tr("KGameQuizLocalizable", "start")
  /// Totale
  public static let totale = KGameQuizLocalization.tr("KGameQuizLocalizable", "totale")
  /// Annulla
  public static let undo = KGameQuizLocalization.tr("KGameQuizLocalizable", "undo")
  /// Si
  public static let yes = KGameQuizLocalization.tr("KGameQuizLocalizable", "yes")
  /// Il tuo punteggio è
  public static let yourScoreIs = KGameQuizLocalization.tr("KGameQuizLocalizable", "your_score_is")

  public enum Error {
    /// Errore generico
    public static let genericError = KGameQuizLocalization.tr("KGameQuizLocalizable", "Error.genericError")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension KGameQuizLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let libLocalized = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    let format = Bundle.main.localizedString(forKey: key, value: libLocalized, table: nil)
    return String(format: format, locale: Locale.current, arguments: args)
  }
  public static func kGameQuizLocalizable(_ key: String, _ args: CVarArg...) -> String {
    return tr("KGameQuizLocalizable", key, args)
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
