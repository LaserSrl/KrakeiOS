//
//  String.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation

public extension String
{
    /**
     Controlla se la stringa è un possibile URL
     
     - returns: true se la stringa è un URL
     */
    func validateUrl () -> Bool {
        let regex = try! NSRegularExpression(pattern: "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+", options: [.caseInsensitive])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, (self as NSString).length)) != nil
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    /**
     Converte una stringa con tag HTML in una String.
     
     - returns: String
     */
    func htmlToString() -> String? {
        let attributedText: NSAttributedString?
        do {
            #if swift(>=4.0)
                attributedText = try NSAttributedString(data: data(using: String.Encoding.unicode)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            #else
                attributedText = try NSAttributedString(data: data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            #endif
        } catch {
            attributedText = nil
        }
        return attributedText?.string
    }
    
    /**
     Converte una stringa con tag HTML in una NSAttributedString.
     
     - returns: NSAttributedString
     */
    func htmlToAttributedString() -> NSAttributedString? {
        let attributedText: NSAttributedString?
                do {
                    #if swift(>=4.0)
                        attributedText = try NSAttributedString(data: data(using: String.Encoding.unicode)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
                    #else
                        attributedText = try NSAttributedString(data: data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                    #endif
        } catch {
            attributedText = nil
        }
        return attributedText
    }
    
    func decodeBase64() -> [UInt8]? {
        if let data = Data(base64Encoded: self, options: []) {
            return data.bytes
        }
        return nil
    }
    
    /**
     Genera randomicamente una String di una certa lunghezza composta da lettere maiuscole, minuscole e numeri
     
     - parameter len: lunghezza della stringa da generare
     
     - returns: ritorna la stringa generata
     */
     static func randomStringWithLength (_ len : Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString as String
    }
    
    func components<T>(separatedBy separators: [T]) -> [String] where T : StringProtocol {
        var result = [self]
        for separator in separators {
            result = result
                .map { $0.components(separatedBy: separator)}
                .flatMap { $0 }
        }
        return result
    }
}
