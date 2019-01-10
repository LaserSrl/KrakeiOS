//
//  VimeoSessionManager+Upload.swift
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

typealias ErrorBlock = (_ error: NSError?) -> Void

enum UploadTaskDescription: String {
    case UploadVideo = "UploadVideo"
    case UploadVideoProgress = "UploadVideoProgress"
    case DeleteVideo = "DeleteVideo"
}

extension VimeoSessionManager {
    
    func uploadProgressTask(_ destination: String, completionHandler: ((Int?, NSError?) -> Void)?) throws -> URLSessionTask {
        let request = try (requestSerializer as! VimeoRequestSerializer).uploadProgressRequest(destination)
        
        let task = dataTask(with: request, uploadProgress: nil, downloadProgress: nil) { [weak self] (response, responseObject, error) in
            
            guard let strongSelf = self, let completionHandler = completionHandler else {
                return
            }
            
            do {
                let bytesReceived = try (strongSelf.responseSerializer as! VimeoResponseSerializer)
                    .processUploadProgressResponse(response, responseObject: responseObject, error: error)
                completionHandler(bytesReceived, nil)
            } catch let error as NSError {
                completionHandler(nil, error)
            }
        }
        
        task.taskDescription = UploadTaskDescription.UploadVideoProgress.rawValue
        
        return task
    }
    
    func uploadVideoTask(source: URL, destination: String, progress: ((Progress) -> Void)?, completionHandler: ErrorBlock?) throws -> URLSessionUploadTask {
        if let sourceData = try? Data(contentsOf: source) {
            return try uploadVideoTask(source: sourceData,
                                       destination: destination,
                                       progress: progress,
                                       completionHandler: completionHandler)
        } else {
            throw NSError(domain: UploadErrorDomain.Upload.rawValue,
                          code: UploadLocalErrorCode.fileNotFoundException.rawValue,
                          userInfo: nil)
        }
    }
    
    func uploadVideoTask(source: Data, destination: String, startingAt startPosition: Int = 0, progress: ((Progress) -> Void)?, completionHandler: ErrorBlock?) throws -> URLSessionUploadTask {
        
        let request = try (requestSerializer as! VimeoRequestSerializer)
            .uploadVideoRequest(source,
                                destination: destination,
                                startingAt: startPosition)
        
        var dataToUpload: Data? = nil
        if startPosition == 0 {
            dataToUpload = source
        } else {
            autoreleasepool {
                let totalNumberOfBytes = source.count - startPosition
                var chunkToSend = [UInt8](repeating: 0, count: totalNumberOfBytes)
                (source as NSData).getBytes(&chunkToSend, range: NSMakeRange(startPosition, totalNumberOfBytes))
                let valueData = withUnsafePointer(to: &chunkToSend){
                    return Data(bytes: $0, count: totalNumberOfBytes)
                }
                dataToUpload = valueData
            }
        }
        
        let task = uploadTask(with: request,
                              from: dataToUpload,
                                         progress: progress) { [weak self] (response, responseObject, error) in
                                            
                                            guard let
                                                strongSelf = self,
                                                let completionHandler = completionHandler else {
                                                    
                                                    return
                                            }
                                            
                                            do {
                                                try (strongSelf.responseSerializer as! VimeoResponseSerializer)
                                                    .processUploadVideoResponse(response,
                                                                                responseObject: responseObject,
                                                                                error: error)
                                                completionHandler(nil)
                                            } catch let error as NSError {
                                                completionHandler(error)
                                            }
        }
        
        task.taskDescription = UploadTaskDescription.UploadVideo.rawValue
        
        return task
    }
    
    func deleteVideoDataTask(videoUri: String, completionHandler: @escaping ErrorBlock) throws -> URLSessionDataTask {
        let request = try (self.requestSerializer as! VimeoRequestSerializer).deleteVideoRequestWithUri(videoUri)
        
        let task = self.dataTask(with: request, uploadProgress: nil, downloadProgress: nil, completionHandler: { [weak self] (response, responseObject, error) -> Void in
            
            guard let strongSelf = self else {
                return
            }
            
            do {
                try (strongSelf.responseSerializer as! VimeoResponseSerializer).processDeleteVideoResponse(response, responseObject: responseObject, error: error)
                completionHandler(nil)
            } catch let error as NSError {
                completionHandler(error)
            }
            })
        
        task.taskDescription = UploadTaskDescription.DeleteVideo.rawValue
        
        return task
    }
    
}
