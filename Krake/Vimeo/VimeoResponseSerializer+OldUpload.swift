//
//  VimeoResponseSerializer+Upload.swift
//  VimeoUpload
//
//  Created by Alfred Hanssen on 10/21/15.
//  Copyright © 2015 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

extension VimeoResponseSerializer {
    
    fileprivate static let LocationKey = "Location"
    
    func processUploadVideoResponse(_ response: URLResponse?, responseObject: Any?, error: Error?) throws {
        do {
            try checkDataResponseForError(response: response, responseObject: responseObject, error: error)
        } catch let error as NSError {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
    }
    
    func processDeleteVideoResponse(_ response: URLResponse?, responseObject: Any?, error: Error?) throws {
        do {
            try checkDataResponseForError(response: response, responseObject: responseObject, error: error)
        } catch let error as NSError {
            throw error.errorByAddingDomain(UploadErrorDomain.Delete.rawValue)
        }
    }
    
    func processUploadProgressResponse(_ response: URLResponse?, responseObject: Any?, error: Error?) throws -> Int? {
        
        if (response as? HTTPURLResponse)?.statusCode != 308 {
            do {
                try checkDataResponseForError(response: response, responseObject: responseObject, error: error)
            } catch let error as NSError {
                throw error.errorByAddingDomain(UploadErrorDomain.UploadProgress.rawValue)
            }
        }
        
        if let receivedRange = (response as? HTTPURLResponse)?.allHeaderFields["Range"] as? NSString {
            do {
                let regex = try NSRegularExpression(pattern: "\\d+", options: [])
                let matches = regex
                    .matches(in: receivedRange as String,
                        options: [],
                        range: NSMakeRange(0, receivedRange.length))
                    .map{ receivedRange.substring(with: $0.range) }
                return Int(matches[matches.count - 1])
            } catch let error as NSError {
                throw error.errorByAddingDomain(UploadErrorDomain.UploadProgress.rawValue)
            }
        } else {
            throw NSError(domain: UploadErrorDomain.UploadProgress.rawValue, code: -100, userInfo: nil)
        }
    }
    
}
