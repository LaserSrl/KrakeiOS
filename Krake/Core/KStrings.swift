// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
public enum KLocalization {
  /// (Fine corsa)
  public static let lastStop = KLocalization.tr("OCLocalizable", "(Last stop)")
  /// Accetta
  public static let accept = KLocalization.tr("OCLocalizable", "ACCEPT")
  /// Accettato
  public static let accepted = KLocalization.tr("OCLocalizable", "Accepted")
  /// Aggiungi al calendario
  public static let aggiungiAlCalendario = KLocalization.tr("OCLocalizable", "Aggiungi al calendario")
  /// Agosto
  public static let agosto = KLocalization.tr("OCLocalizable", "Agosto")
  /// Arrabbiato
  public static let angry = KLocalization.tr("OCLocalizable", "angry")
  /// Sconosciuto
  public static let anonymous = KLocalization.tr("OCLocalizable", "Anonymous")
  /// Aprile
  public static let aprile = KLocalization.tr("OCLocalizable", "Aprile")
  /// Ora di arrivo?
  public static let arriveby = KLocalization.tr("OCLocalizable", "ARRIVEBY")
  /// Arrivo
  public static let arrivo = KLocalization.tr("OCLocalizable", "Arrivo")
  /// Il gioco sarà disponibile dal
  public static let availableSoon = KLocalization.tr("OCLocalizable", "available_soon")
  /// Scarsa qualità del segnale GPS
  public static let badLocationAccuracy = KLocalization.tr("OCLocalizable", "Bad location accuracy")
  /// Vai in bici fino a 
  public static let bicycle = KLocalization.tr("OCLocalizable", "BICYCLE")
  /// Il Bluetooth non è supportato da questo dispositivo
  public static let bluetoothIsNotSupportedByYourDevice = KLocalization.tr("OCLocalizable", "Bluetooth is not supported by your device")
  /// Noioso
  public static let boring = KLocalization.tr("OCLocalizable", "boring")
  /// Bravo!
  public static let bravo = KLocalization.tr("OCLocalizable", "bravo")
  /// In bus
  public static let bus = KLocalization.tr("OCLocalizable", "BUS")
  ///  per 
  public static let by = KLocalization.tr("OCLocalizable", "BY")
  /// Cambi
  public static let cambi = KLocalization.tr("OCLocalizable", "Cambi")
  /// Non vi sono fermate nei pressi della zona evidenziata
  public static let canNotFindStops = KLocalization.tr("OCLocalizable", "CAN_NOT_FIND_STOPS")
  /// Non è stato possibile caricare l'itinerario
  public static let canNotTrip = KLocalization.tr("OCLocalizable", "CAN_NOT_TRIP")
  /// Annulla
  public static let cancel = KLocalization.tr("OCLocalizable", "Cancel")
  /// Guida fino a
  public static let car = KLocalization.tr("OCLocalizable", "CAR")
  /// Categoria
  public static let categoria = KLocalization.tr("OCLocalizable", "Categoria")
  /// Confermi di voler inviare il seguente numero?\n\n
  public static let checkYourNumber = KLocalization.tr("OCLocalizable", "check_your_number")
  /// Scegli o scatta una foto
  public static let chooseTakePhoto = KLocalization.tr("OCLocalizable", "CHOOSE_TAKE_PHOTO")
  /// Chiudi
  public static let close = KLocalization.tr("OCLocalizable", "CLOSE")
  /// Uso commerciale
  public static let commercialUse = KLocalization.tr("OCLocalizable", "CommercialUse")
  /// Completato
  public static let completed = KLocalization.tr("OCLocalizable", "Completed")
  /// Condividi
  public static let condividi = KLocalization.tr("OCLocalizable", "Condividi")
  /// Conferma la password
  public static let confirmPassword = KLocalization.tr("OCLocalizable", "confirm_password")
  /// I tuoi punti sono stati salvati correttamente.
  public static let contestParticipate = KLocalization.tr("OCLocalizable", "contest_participate")
  /// Continua
  public static let continua = KLocalization.tr("OCLocalizable", "continua")
  /// Creato
  public static let created = KLocalization.tr("OCLocalizable", "Created")
  /// Curioso
  public static let curious = KLocalization.tr("OCLocalizable", "curious")
  /// Nega
  public static let deny = KLocalization.tr("OCLocalizable", "DENY")
  /// Descrizione
  public static let descrizione = KLocalization.tr("OCLocalizable", "Descrizione")
  /// Devi scattare o scegliere una foto
  public static let deviScattareOScegliereUnaFoto = KLocalization.tr("OCLocalizable", "Devi scattare o scegliere una foto")
  /// Errore nel device.\nContatta l'amministratore.
  public static let deviceError = KLocalization.tr("OCLocalizable", "DEVICE_ERROR")
  /// Dicembre
  public static let dicembre = KLocalization.tr("OCLocalizable", "Dicembre")
  /// in direzione
  public static let directionBy = KLocalization.tr("OCLocalizable", "direction_by")
  /// Dopo %s
  public static func directionDescriptionAfter(_ p1: UnsafePointer<CChar>) -> String {
    return KLocalization.tr("OCLocalizable", "direction_description_after", p1)
  }
  /// Alla rotonda prendi la %@ uscita
  public static func directionDescriptionCircle(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "direction_description_circle", String(describing: p1))
  }
  /// Continua
  public static let directionDescriptionContinue = KLocalization.tr("OCLocalizable", "direction_description_continue")
  /// Parti
  public static let directionDescriptionDepart = KLocalization.tr("OCLocalizable", "direction_description_depart")
  /// Gira a sinistra
  public static let directionDescriptionHardLeft = KLocalization.tr("OCLocalizable", "direction_description_hard_left")
  /// Gira a destra
  public static let directionDescriptionHardRight = KLocalization.tr("OCLocalizable", "direction_description_hard_right")
  /// Svolta a sinistra
  public static let directionDescriptionLeft = KLocalization.tr("OCLocalizable", "direction_description_left")
  /// Svolta a destra
  public static let directionDescriptionRight = KLocalization.tr("OCLocalizable", "direction_description_right")
  /// Gira lievemente a sinistra
  public static let directionDescriptionSlightlyLeft = KLocalization.tr("OCLocalizable", "direction_description_slightly_left")
  /// Gira lievemente a destra
  public static let directionDescriptionSlightlyRight = KLocalization.tr("OCLocalizable", "direction_description_slightly_right")
  /// Fai inversione a U
  public static let directionDescriptionUturn = KLocalization.tr("OCLocalizable", "direction_description_uturn")
  /// Dominio
  public static let domain = KLocalization.tr("OCLocalizable", "domain")
  /// Domenica
  public static let domenica = KLocalization.tr("OCLocalizable", "Domenica")
  /// Conferma
  public static let done = KLocalization.tr("OCLocalizable", "Done")
  /// Trascina per spostare
  public static let dragToMove = KLocalization.tr("OCLocalizable", "Drag to move")
  /// Hai già un device registrato.\nContatta l'amministratore.
  public static let duplicateContainer = KLocalization.tr("OCLocalizable", "DUPLICATE_CONTAINER")
  /// Durata
  public static let durata = KLocalization.tr("OCLocalizable", "Durata")
  /// E-Mail
  public static let eMail = KLocalization.tr("OCLocalizable", "e_mail")
  /// Campo non compilato
  public static let emptyField = KLocalization.tr("OCLocalizable", "empty_field")
  /// Abilita la localizzazione e il Bluetooth per poter utilizzare la funzionalità
  public static let enableBluetoothToOpenTheTurnstiles = KLocalization.tr("OCLocalizable", "Enable Bluetooth to open the turnstiles")
  /// Per poter procedere verifica di:\n- avere configurato nei setting del device l’account di Facebook oppure di avere l’app di Facebook installata\n- avere abilitato l’app su Facebook\n\nAttenzione: se di recente hai cambiato la password di Facebook ricordati di aggiornarla anche nei setting del device o nell’app Facebook.
  public static let enableFacebook = KLocalization.tr("OCLocalizable", "ENABLE_FACEBOOK")
  /// Vuoi procedere?
  public static let enableNow = KLocalization.tr("OCLocalizable", "ENABLE_NOW")
  /// Per accedere a questa sezione devi prima aver autorizzato Twitter dalle impostazioni!
  public static let enableTwitter = KLocalization.tr("OCLocalizable", "ENABLE_TWITTER")
  /// Errore
  public static let error = KLocalization.tr("OCLocalizable", "Error")
  /// Non ci sono tweet da visualizzare
  public static let errorDataTweets = KLocalization.tr("OCLocalizable", "error-data-tweets")
  /// Non ci sono tweet da visualizzare
  public static let errorDownloadConfigTweets = KLocalization.tr("OCLocalizable", "error-download-config-tweets")
  /// Non ci sono tweet da visualizzare
  public static let errorGuestSessionTweets = KLocalization.tr("OCLocalizable", "error-guest-session-tweets")
  /// Non ci sono tweet da visualizzare
  public static let errorRequestTweets = KLocalization.tr("OCLocalizable", "error-request-tweets")
  /// Non ci sono tweet da visualizzare
  public static let errorZeroTweets = KLocalization.tr("OCLocalizable", "error-zero-tweets")
  /// Inserisci la tua posizione
  public static let erroreGps = KLocalization.tr("OCLocalizable", "ERRORE_GPS")
  /// ERRORE: Non è stato possibile inviare la segnalazione.\n
  public static let erroreInvioSegn = KLocalization.tr("OCLocalizable", "ERRORE_INVIO_SEGN")
  /// Evento aggiunto al calendario
  public static let eventAdded = KLocalization.tr("OCLocalizable", "event_added")
  /// Emozionato
  public static let excited = KLocalization.tr("OCLocalizable", "excited")
  /// Esausto
  public static let exhausted = KLocalization.tr("OCLocalizable", "exhausted")
  /// Facebook login
  public static let fblogin = KLocalization.tr("OCLocalizable", "FBLOGIN")
  /// Febbraio
  public static let febbraio = KLocalization.tr("OCLocalizable", "Febbraio")
  /// Cerca fermate vicino a
  public static let findStopsNearby = KLocalization.tr("OCLocalizable", "FIND_STOPS_NEARBY")
  /// Da
  public static let from = KLocalization.tr("OCLocalizable", "FROM")
  /// dal %@ al %@
  public static func fromToDate(_ p1: Any, _ p2: Any) -> String {
    return KLocalization.tr("OCLocalizable", "fromToDate", String(describing: p1), String(describing: p2))
  }
  /// dalle %@ alle %@
  public static func fromToHour(_ p1: Any, _ p2: Any) -> String {
    return KLocalization.tr("OCLocalizable", "fromToHour", String(describing: p1), String(describing: p2))
  }
  /// galleria
  public static let gallery = KLocalization.tr("OCLocalizable", "Gallery")
  /// Vuoi autenticarti adesso?
  public static let gameCenterLoginNow = KLocalization.tr("OCLocalizable", "game_center_login_now")
  /// Game Center è richiesto per partecipare al quiz.
  public static let gameCenterRequest = KLocalization.tr("OCLocalizable", "game_center_request")
  /// Gennaio
  public static let gennaio = KLocalization.tr("OCLocalizable", "Gennaio")
  /// Gestione policy
  public static let gestionePolicy = KLocalization.tr("OCLocalizable", "gestione_policy")
  /// Giovedì
  public static let giovedì = KLocalization.tr("OCLocalizable", "Giovedì")
  /// Giugno
  public static let giugno = KLocalization.tr("OCLocalizable", "Giugno")
  /// Felice
  public static let happy = KLocalization.tr("OCLocalizable", "happy")
  /// Ricorda che devi abilitare l'app dalle impostazioni di sistema.
  public static let helpfb = KLocalization.tr("OCLocalizable", "HELPFB")
  /// Mi piace
  public static let iLike = KLocalization.tr("OCLocalizable", "i Like")
  /// Ci sono stato
  public static let iWasThere = KLocalization.tr("OCLocalizable", "i Was There")
  /// Impostazioni
  public static let impostazioni = KLocalization.tr("OCLocalizable", "Impostazioni")
  /// in arrivo
  public static let inArrivo = KLocalization.tr("OCLocalizable", "in arrivo")
  /// Inserisci il testo da cercare
  public static let insertTextToSearch = KLocalization.tr("OCLocalizable", "Insert text to search")
  /// inserisci il tuo numero
  public static let insertPhoneNumber = KLocalization.tr("OCLocalizable", "insert_phone_number")
  /// Interessato
  public static let interested = KLocalization.tr("OCLocalizable", "interested")
  /// Entry Point non valido
  public static let invalidEntryPoint = KLocalization.tr("OCLocalizable", "invalid_entry_point")
  /// Scherzo
  public static let joke = KLocalization.tr("OCLocalizable", "joke")
  /// Bacio
  public static let kiss = KLocalization.tr("OCLocalizable", "kiss")
  /// La mia posizione
  public static let lamiapos = KLocalization.tr("OCLocalizable", "LAMIAPOS")
  /// it-IT
  public static let language = KLocalization.tr("OCLocalizable", "LANGUAGE")
  /// Abbandona
  public static let leave = KLocalization.tr("OCLocalizable", "leave")
  /// Linea %@ - %@ %@
  public static func lineaVerso(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return KLocalization.tr("OCLocalizable", "Linea %@ verso %@ %@", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Caricato
  public static let loaded = KLocalization.tr("OCLocalizable", "Loaded")
  /// Posizione
  public static let location = KLocalization.tr("OCLocalizable", "LOCATION")
  /// Accedi
  public static let login = KLocalization.tr("OCLocalizable", "login")
  /// Accedi con
  public static let loginWith = KLocalization.tr("OCLocalizable", "LOGIN_WITH")
  /// Password dimenticata?
  public static let lostPwd = KLocalization.tr("OCLocalizable", "lost_pwd")
  /// Amore
  public static let love = KLocalization.tr("OCLocalizable", "love")
  /// Luglio
  public static let luglio = KLocalization.tr("OCLocalizable", "Luglio")
  /// Lunedì
  public static let lunedì = KLocalization.tr("OCLocalizable", "Lunedì")
  /// Maggio
  public static let maggio = KLocalization.tr("OCLocalizable", "Maggio")
  /// Inserisci il nome del destinatario
  public static let mancaIlNomeDelDestinatario = KLocalization.tr("OCLocalizable", "Manca il nome del destinatario")
  /// Inserisci il tuo nome
  public static let mancaIlNomeDelMittente = KLocalization.tr("OCLocalizable", "Manca il nome del mittente")
  /// Inserisci il tuo commento
  public static let mancaIlTestoDelMessaggio = KLocalization.tr("OCLocalizable", "Manca il testo del messaggio")
  /// Inserisci la mail del destinatario
  public static let mancaLaEMailDelDestinatario = KLocalization.tr("OCLocalizable", "Manca la E-Mail del destinatario")
  /// Inserisci la tua mail
  public static let mancaLaEMailDelMittente = KLocalization.tr("OCLocalizable", "Manca la E-Mail del mittente")
  /// Mancano i seguenti campi:
  public static let mancanoISeguentiCampi = KLocalization.tr("OCLocalizable", "Mancano i seguenti campi:")
  /// Mappa
  public static let mappa = KLocalization.tr("OCLocalizable", "Mappa")
  /// Martedì
  public static let martedì = KLocalization.tr("OCLocalizable", "Martedì")
  /// Marzo
  public static let marzo = KLocalization.tr("OCLocalizable", "Marzo")
  /// Hai raggiunto il numero massimo di elementi multimediali. Prima di procedere con l'aggiunta di un nuovo elemento devi cancellarne uno.
  public static let mediaMaxNumberOfElem = KLocalization.tr("OCLocalizable", "media_max_number_of_elem")
  /// Mercoledì
  public static let mercoledì = KLocalization.tr("OCLocalizable", "Mercoledì")
  /// Messaggio
  public static let message = KLocalization.tr("OCLocalizable", "MESSAGE")
  /// Ci sono stati problemi di connessione
  public static let networkUnreachable = KLocalization.tr("OCLocalizable", "Network unreachable")
  /// Avanti
  public static let next = KLocalization.tr("OCLocalizable", "next")
  /// No
  public static let no = KLocalization.tr("OCLocalizable", "No")
  /// Non hai diritto a credenziali di accesso.\nContatta l'amministratore.
  public static let noCredentialEnabled = KLocalization.tr("OCLocalizable", "NO_CREDENTIAL_ENABLED")
  /// Non ci sono elementi in questa sezione
  public static let noElements = KLocalization.tr("OCLocalizable", "no_elements")
  /// Nome della fermata
  public static let nomeDellaFermata = KLocalization.tr("OCLocalizable", "Nome della fermata")
  /// Novembre
  public static let novembre = KLocalization.tr("OCLocalizable", "Novembre")
  /// %@
  public static func on(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "on", String(describing: p1))
  }
  /// Caricamento in corso...
  public static let onLoading = KLocalization.tr("OCLocalizable", "on_loading")
  /// Ops!
  public static let ops = KLocalization.tr("OCLocalizable", "ops")
  /// ore %@
  public static func ore(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "ore %@", String(describing: p1))
  }
  /// Disattiva le notifiche per tutte le fermate.
  public static let otpDisableAllStopsNotification = KLocalization.tr("OCLocalizable", "OTP_DISABLE_ALL_STOPS_NOTIFICATION")
  /// Vuoi disabilitare tutte le notifiche?
  public static let otpDisableAllStopsNotificationQuestion = KLocalization.tr("OCLocalizable", "OTP_DISABLE_ALL_STOPS_NOTIFICATION_QUESTION")
  /// Vuoi disabilitare la notifica?
  public static let otpDisableStopNotification = KLocalization.tr("OCLocalizable", "OTP_DISABLE_STOP_NOTIFICATION_?")
  /// Vuoi essere notificato quando sei nei paraggi della fermata?
  public static let otpEnableStopNotification = KLocalization.tr("OCLocalizable", "OTP_ENABLE_STOP_NOTIFICATION_?")
  /// Abilita sempre la localizzazione per usufruire della funzionalità.
  public static let otpLocalizationError = KLocalization.tr("OCLocalizable", "OTP_LOCALIZATION_ERROR")
  /// Attenzione: puoi attivare un massimo di 20 fermate; prima di procedere con l'attivazione di una nuova fermata, devi disabilitarne un'altra.
  public static let otpMaxNumberOfRegion = KLocalization.tr("OCLocalizable", "OTP_MAX_NUMBER_OF_REGION")
  /// Stai per arrivare alla fermata '%@'
  public static func otpStopNotification(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "OTP_STOP_NOTIFICATION", String(describing: p1))
  }
  /// Ottobre
  public static let ottobre = KLocalization.tr("OCLocalizable", "Ottobre")
  /// Panico
  public static let pain = KLocalization.tr("OCLocalizable", "pain")
  /// Partecipa
  public static let partecipate = KLocalization.tr("OCLocalizable", "partecipate")
  /// Partenza
  public static let partenza = KLocalization.tr("OCLocalizable", "Partenza")
  /// Password
  public static let password = KLocalization.tr("OCLocalizable", "password")
  /// Percorso a piedi
  public static let percorsoAPiedi = KLocalization.tr("OCLocalizable", "Percorso a piedi")
  /// Percorso più veloce
  public static let percorsoPiùVeloce = KLocalization.tr("OCLocalizable", "Percorso più veloce")
  /// Numero di cellulare
  public static let phoneNumber = KLocalization.tr("OCLocalizable", "phone_number")
  /// Avvicina il tuo device al lettore per utilizzare la funzionalità
  public static let placeYourSmartphoneNearTheTurnstileToOpenIt = KLocalization.tr("OCLocalizable", "Place your smartphone near the turnstile to open it.")
  /// E-Mail
  public static let placeholderMailRestorePassword = KLocalization.tr("OCLocalizable", "placeholder_mail_restore_password")
  /// Numero di telefono o la E-Mail
  public static let placeholderSmsOrMailRestorePassword = KLocalization.tr("OCLocalizable", "placeholder_sms_or_mail_restore_password")
  /// ATTENDERE PREGO
  public static let pleaseWaiting = KLocalization.tr("OCLocalizable", "please_waiting")
  /// Policies
  public static let policy = KLocalization.tr("OCLocalizable", "Policy")
  /// Accetto i suddetti termini.
  public static let policyTerm = KLocalization.tr("OCLocalizable", "policy-term")
  /// Ci sono stati problemi con il Bluetooth.
  public static let problemsWithBluetooth = KLocalization.tr("OCLocalizable", "Problems with Bluetooth")
  /// punti
  public static let punti = KLocalization.tr("OCLocalizable", "punti")
  /// Per accedere a questa sezione devi prima aver attivato le Push!
  public static let pushActivation = KLocalization.tr("OCLocalizable", "PUSH_ACTIVATION")
  /// Grazie per aver compilato il questionario
  public static let questionnaireCompleted = KLocalization.tr("OCLocalizable", "QUESTIONNAIRE_COMPLETED")
  /// Non è stato possibile spedire il tuo questionario
  public static let questionnaireError = KLocalization.tr("OCLocalizable", "QUESTIONNAIRE_ERROR")
  /// Complimenti, hai già compilato tutti i questionari. Torna presto a trovarci per contribuire ancora!
  public static let questionnaireNotAvailable = KLocalization.tr("OCLocalizable", "QUESTIONNAIRE_NOT_AVAILABLE")
  /// Non hai risposto a nessuna domanda
  public static let questionnaireNotCompiled = KLocalization.tr("OCLocalizable", "QUESTIONNAIRE_NOT_COMPILED")
  /// Devi compilare la domanda '%@' prima di poter inviare il questionario
  public static func questionnaireQuestionRequired(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "QUESTIONNAIRE_QUESTION_REQUIRED", String(describing: p1))
  }
  /// Sei pronto per continuare la partita?
  public static let ruReady = KLocalization.tr("OCLocalizable", "r_u_ready")
  /// Sei pronto per iniziare la partita?
  public static let ready = KLocalization.tr("OCLocalizable", "ready")
  /// Errore, prova a riavviare l'app o il device. Se il problema persiste contatta l'amministratore
  public static let rebootAppDevice = KLocalization.tr("OCLocalizable", "REBOOT_APP_DEVICE")
  /// Recupera password
  public static let recoverPassword = KLocalization.tr("OCLocalizable", "Recover_password")
  /// Registrati
  public static let register = KLocalization.tr("OCLocalizable", "Register")
  /// Registrazione
  public static let registration = KLocalization.tr("OCLocalizable", "Registration")
  /// Accetto i suddetti termini.
  public static let regulationTerm = KLocalization.tr("OCLocalizable", "regulation-term")
  /// Rifiutato
  public static let rejected = KLocalization.tr("OCLocalizable", "Rejected")
  /// Info generali
  public static let relatedFields = KLocalization.tr("OCLocalizable", "RELATED_FIELDS")
  ///  *obbligatorio
  public static let `required` = KLocalization.tr("OCLocalizable", "required")
  /// Ti abbiamo appena inviato la tua nuova password.
  public static let resetPasswordSended = KLocalization.tr("OCLocalizable", "reset_password_sended")
  /// Password dimenticata? Compila il form e riceverai un link per il reset della password.
  public static let resetPwdMessage = KLocalization.tr("OCLocalizable", "reset_pwd_message")
  /// Risposta corretta.
  public static let rispostaCorretta = KLocalization.tr("OCLocalizable", "risposta_corretta")
  /// Risposta errata.
  public static let rispostaErrata = KLocalization.tr("OCLocalizable", "risposta_errata")
  /// Sabato
  public static let sabato = KLocalization.tr("OCLocalizable", "Sabato")
  /// Triste
  public static let sad = KLocalization.tr("OCLocalizable", "sad")
  /// Salva
  public static let save = KLocalization.tr("OCLocalizable", "SAVE")
  /// Cerca
  public static let search = KLocalization.tr("OCLocalizable", "SEARCH")
  /// Errore nella ricerca dell'utente\nContatta l'amministratore
  public static let searchError = KLocalization.tr("OCLocalizable", "SEARCH_ERROR")
  /// La tua segnalazione è stata inviata correttamente.\n
  public static let segnSended = KLocalization.tr("OCLocalizable", "SEGN_SENDED")
  /// Invia
  public static let send = KLocalization.tr("OCLocalizable", "SEND")
  /// Errore.\nContatta l'amministratore.
  public static let serviceNotAvailable = KLocalization.tr("OCLocalizable", "SERVICE_NOT_AVAILABLE")
  /// Settembre
  public static let settembre = KLocalization.tr("OCLocalizable", "Settembre")
  /// Scioccato
  public static let shocked = KLocalization.tr("OCLocalizable", "shocked")
  /// Si
  public static let si = KLocalization.tr("OCLocalizable", "Si")
  /// Silenzioso
  public static let silent = KLocalization.tr("OCLocalizable", "silent")
  /// Sito web
  public static let sitoWeb = KLocalization.tr("OCLocalizable", "Sito web")
  /// Numero non valido
  public static let smsNotValid = KLocalization.tr("OCLocalizable", "sms_not_valid")
  /// Sottotitolo
  public static let sottotitolo = KLocalization.tr("OCLocalizable", "Sottotitolo")
  /// Inizia
  public static let start = KLocalization.tr("OCLocalizable", "start")
  /// Fermata
  public static let stop = KLocalization.tr("OCLocalizable", "STOP")
  /// Metro
  public static let subway = KLocalization.tr("OCLocalizable", "SUBWAY")
  /// Telefono
  public static let telefono = KLocalization.tr("OCLocalizable", "Telefono")
  /// Cessione dati
  public static let thirdParty = KLocalization.tr("OCLocalizable", "ThirdParty")
  /// Titolo
  public static let titolo = KLocalization.tr("OCLocalizable", "Titolo")
  /// A
  public static let to = KLocalization.tr("OCLocalizable", "TO")
  /// al
  public static let toDate = KLocalization.tr("OCLocalizable", "To-date")
  /// A e-mail
  public static let toMail = KLocalization.tr("OCLocalizable", "TO_MAIL")
  /// A nome
  public static let toName = KLocalization.tr("OCLocalizable", "TO_NAME")
  /// Totale
  public static let totale = KLocalization.tr("OCLocalizable", "totale")
  /// In tram
  public static let tram = KLocalization.tr("OCLocalizable", "TRAM")
  /// Stiamo calcolando il percorso
  public static let tripRoute = KLocalization.tr("OCLocalizable", "trip_route")
  /// Arrivo entro
  public static let tripModeArrivo = KLocalization.tr("OCLocalizable", "tripModeArrivo")
  /// Partenza
  public static let tripModePartenza = KLocalization.tr("OCLocalizable", "tripModePartenza")
  /// Non è stato possibile aprire il tornello (Anti Passback). Riprova più tardi.
  public static let turnslideErrorAntipassback = KLocalization.tr("OCLocalizable", "TURNSLIDE_ERROR_ANTIPASSBACK")
  /// Tornello aperto!
  public static let turnstileOpened = KLocalization.tr("OCLocalizable", "Turnstile opened!")
  /// Tutti
  public static let tutti = KLocalization.tr("OCLocalizable", "Tutti")
  /// Annulla
  public static let undo = KLocalization.tr("OCLocalizable", "UNDO")
  /// Per procedere devi accettare l'informativa.
  public static let undoPrivacy = KLocalization.tr("OCLocalizable", "undo_privacy")
  /// Utente non registrato sui sistemi.\nContatta l'amministratore
  public static let userNotExist = KLocalization.tr("OCLocalizable", "USER_NOT_EXIST")
  /// Utente duplicato\nContatta l'amministratore
  public static let userNotUnique = KLocalization.tr("OCLocalizable", "USER_NOT_UNIQUE")
  /// Venerdì
  public static let venerdì = KLocalization.tr("OCLocalizable", "Venerdì")
  /// Il tuo indirizzo di email é stato verificato
  public static let verificationMailMessage = KLocalization.tr("OCLocalizable", "VerificationMailMessage")
  /// %@\n\nVuoi saperne di più?
  public static func vuoiAprirePush(_ p1: Any) -> String {
    return KLocalization.tr("OCLocalizable", "VUOI_APRIRE_PUSH", String(describing: p1))
  }
  /// Attendere
  public static let wait = KLocalization.tr("OCLocalizable", "wait")
  /// Attendi alcuni istanti.\nElaborazione in corso.
  public static let waitConfiguring = KLocalization.tr("OCLocalizable", "WAIT_CONFIGURING")
  /// Cammina per
  public static let walk = KLocalization.tr("OCLocalizable", "WALK")
  /// La tua e-mail
  public static let yourMail = KLocalization.tr("OCLocalizable", "YOUR_MAIL")
  /// Il tuo nome
  public static let yourName = KLocalization.tr("OCLocalizable", "YOUR_NAME")
  /// Il tuo punteggio è
  public static let yourScoreIs = KLocalization.tr("OCLocalizable", "your_score_is")
  /// %0.f minuti
  public static let _0FMinuti = KLocalization.tr("OCLocalizable", "%0.f minuti")
  /// messaggio
  public static let bodyPartText = KLocalization.tr("OCLocalizable", "BodyPart.Text")
  /// posizione GPS
  public static let mapPartLatitude = KLocalization.tr("OCLocalizable", "MapPart.Latitude")
  /// Il servizio è momentaneamente occupato. Riprova più tardi.
  public static let theServiceIsTemporarilyBusyRetryLater = KLocalization.tr("OCLocalizable", "The service is temporarily busy. Retry later.")
  /// titolo
  public static let titlePartTitle = KLocalization.tr("OCLocalizable", "TitlePart.Title")
  /// Non è stato possibile calcolare il tragitto richiesto in quanto è fuori dall'area prevista.
  public static let tripIsNotPossibleYouMightBeTryingToPlanATripOutsideTheMapDataBoundary = KLocalization.tr("OCLocalizable", "Trip is not possible.  You might be trying to plan a trip outside the map data boundary.")
  /// Non è stato possibile aprire il tornello. Riprova più tardi.
  public static let unableToOpenTheTurnstileRetryLater = KLocalization.tr("OCLocalizable", "Unable to open the turnstile. Retry later.")
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length

// MARK: - Implementation Details

extension KLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(url: Bundle.main.url(forResource: "Localization", withExtension: "bundle")!)!
    #endif
  }()
}
// swiftlint:enable convenience_type
