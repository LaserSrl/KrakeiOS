//
//  VimeoUploader.swift
//  Pods
//
//  Created by Marco Zanino on 21/07/16.
//
//

import Foundation

open class VimeoUploader {
    
    open class func startVideoUpload(_ videoURL: URL?,
                                       mediaPartId: Int?,
                                       taskShouldFail failing: Bool = false,
                                                      success successCompletion: MediaUploadSuccess?,
                                                              failure failureCompletion: MediaUploadError?) -> URLSessionTask? {
        
        guard let videoURL = videoURL else {
            return nil
        }
        
        do {
            let vimeoUploadTask = try VimeoVideoUploadTask(fileURL: videoURL, mediaPartId: mediaPartId)
            vimeoUploadTask.shouldFail = failing
            vimeoUploadTask.completionHandler = successCompletion
            vimeoUploadTask.errorHandler = failureCompletion
            vimeoUploadTask.resume()
            return vimeoUploadTask
        } catch let error as NSError {
            failureCompletion?(error)
            return nil
        }
    }
    
}
