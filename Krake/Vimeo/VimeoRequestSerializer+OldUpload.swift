//
//  VimeoRequestSerializer+Upload.swift
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
import AVFoundation

extension VimeoRequestSerializer {
    
    func uploadProgressRequest(_ destination: String) throws -> URLRequest {
        var error: NSError?
        let request = self.request(withMethod: "PUT", urlString: destination, parameters: nil, error: &error)
        if let error = error {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        request.setValue("bytes */*", forHTTPHeaderField: "Content-Range")
        request.setValue("video/mp4", forHTTPHeaderField: "X-Upload-Content-Type")
        
        return request as URLRequest
    }
    
    func uploadVideoRequest(_ fileContent: Data, destination: String, startingAt startByte: Int) throws -> URLRequest {
        var error: NSError?
        let request = self.request(withMethod: "PUT", urlString: destination, parameters: nil, error: &error)
        if let error = error {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        let fileSize = fileContent.bytes.count
        
        request.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
        request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        request.setValue("bytes \(startByte)-\(fileSize)/\(fileSize)", forHTTPHeaderField: "Content-Range")
        
        return request as URLRequest
    }
    
    func uploadVideoRequestWithSource(_ source: URL, destination: String) throws -> URLRequest {
        guard FileManager.default.fileExists(atPath: source.path) else {
            throw NSError(domain: UploadErrorDomain.Upload.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Attempt to construct upload request but the source file does not exist."])
        }
        
        var error: NSError?
        let request = self.request(withMethod: "PUT", urlString: destination, parameters: nil, error: &error)
        if let error = error {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        let asset = AVURLAsset(url: source)
        
        let fileSize: NSNumber
        do {
            fileSize = try asset.fileSize()
        } catch let error as NSError {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        request.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
        request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        
        // For resumed uploads on a single upload ticket we must include this header per @naren (undocumented) [AH] 12/25/2015
        request.setValue("bytes 0-\(fileSize)/\(fileSize)", forHTTPHeaderField: "Content-Range")
        
        return request as URLRequest
    }
    
    func deleteVideoRequestWithUri(_ videoUri: String) throws -> URLRequest {
        guard videoUri.count > 0 else {
            throw NSError(domain: UploadErrorDomain.Delete.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "videoUri has length of 0."])
        }
        
        let url = URL(string: videoUri, relativeTo: VimeoBaseURLString as URL?)!
        var error: NSError?
        
        let request = self.request(withMethod: "DELETE", urlString: url.absoluteString, parameters: nil, error: &error)
        if let error = error {
            throw error.errorByAddingDomain(UploadErrorDomain.Delete.rawValue)
        }
        
        return request as URLRequest
    }
    
}
