// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum KPuzzleGameLocalization {
  /// Chiudi il gioco
  public static let closeGame = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "CloseGame")
  /// Complimenti
  public static let congrats = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "Congrats")
  /// Hai perso!
  public static let failedGame = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "FailedGame")
  /// Riprendi
  public static let resume = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "Resume")
  /// Vuoi vedere l'immagine completa?
  public static let showCompleteImageQuestion = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "ShowCompleteImageQuestion")
  /// Vuoi vedere il numero delle tessere?
  public static let showTilesQuestion = KPuzzleGameLocalization.tr("KPuzzleGameLocalizable", "ShowTilesQuestion")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension KPuzzleGameLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let libLocalized = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    let format = Bundle.main.localizedString(forKey: key, value: libLocalized, table: nil)
    return String(format: format, locale: Locale.current, arguments: args)
  }
  public static func kPuzzleGameLocalizable(_ key: String, _ args: CVarArg...) -> String {
    return tr("KPuzzleGameLocalizable", key, args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(url: Bundle.main.url(forResource: "PuzzleGame", withExtension: "bundle")!)!
    #endif
  }()
}
// swiftlint:enable convenience_type
