//
//  VimeoVideoUploadTask.swift
//  Pods
//
//  Created by Marco Zanino on 19/07/16.
//
//

import Foundation
import AFNetworking

public typealias MediaUploadSuccess = (Int, Bool) -> Void
public typealias MediaUploadError = (Error?) -> Void

extension KErrorCode
{
    public static let userStopped: Int = 3001
    public static let uploadStopped: Int = 3002
    public static let uploadMayResume: Int = 3003
}

class VimeoVideoUploadTask: URLSessionTask {
    
    fileprivate lazy var completionQueue = OperationQueue.main
    
    fileprivate let videoURL: URL
    fileprivate let contentToUpload: Data
    
    fileprivate var contentId: Int?
    fileprivate var vimeoStringURL: String?
    /// Manager of the sessions for the internal WS.
    /// Base manager of the sessions for the internal WS.
    /// Never use this manager directly, instead use errorSessionManager to report
    /// errors to Krake and krakeVimeoSessionManager for all the other calls.
    fileprivate lazy var sessionManager: KNetworkManager = {
        let vimeoApiURL = KInfoPlist.KrakePlist.path
            .appendingPathComponent(KAPIConstants.vimeo)
        let manager = KNetworkManager(baseURL: vimeoApiURL, auth: true)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.completionQueue = DispatchQueue.global()
        return manager
    }()
    fileprivate var krakeVimeoSessionManager: KNetworkManager {
        let manager = self.sessionManager
        manager.requestSerializer = KrakeVimeoRequestSerializer()
        return manager
    }
    fileprivate var errorSessionManager: KNetworkManager {
        let manager = self.sessionManager
        manager.requestSerializer = AFJSONRequestSerializer()
        return manager
    }
    /// Manager of the sessions for Vimeo WS.
    fileprivate lazy var vimeoSessionManager: VimeoSessionManager = {
        let vimeoAccessToken = KInfoPlist.Vimeo.accessToken
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        return VimeoSessionManager(sessionConfiguration: sessionConfiguration, authToken: vimeoAccessToken)
    }()
    /// The active task. If its status is completed, than nil will be returned.
    var activeTask: URLSessionTask?
    /// Descriptors for the state and the error.
    fileprivate var internalState: URLSessionTask.State
    fileprivate var internalError: Error? {
        didSet {
            if internalError != nil {
                completionQueue.addOperation { [weak self] in
                    if let strongSelf = self {
                        strongSelf.errorHandler?(strongSelf.internalError!)
                    }
                }
            }
        }
    }
    
    fileprivate var videoContentAlreadyReceivedByVimeo: Int64 = 0
    fileprivate var videoContentSendedBytes: Int64 = 0
    
    // MARK: - Completion handlers
    
    var completionHandler: MediaUploadSuccess?
    var errorHandler: MediaUploadError?
    
    // MARK: - Deinits
    
    deinit {
        activeTask?.cancel()
    }
    
    // MARK: - Initialization methods
    
    init(fileURL url: URL, mediaPartId: Int?) throws {
        if let dataToUpload = try? Data(contentsOf: url) {
            videoURL = url
            contentToUpload = dataToUpload
            contentId = mediaPartId
            internalState = .running
            activeTask = nil
            super.init()
        } else {
            throw NSError(domain: VimeoUploaderErrorDomain,
                          code: VimeoUploaderErrorCode.genericError.rawValue)
        }
    }
    
    // MARK: - Media part detaching
    
    var shouldFail = false
    
    /**
     Start requesting to our WS the id of the MediaPart that will be associated
     to this video and the Vimeo url to upload this video.
     */
    fileprivate func requestUploadInformation() {
        let params: [String : Any]?
        
        #if DEBUG
            if shouldFail {
                params = nil
            } else {
                params = ["fileSize" : contentToUpload.bytes.count]
            }
        #else
            params = ["fileSize" : contentToUpload.bytes.count]
        #endif
        
        let retrieveVideoURL = krakeVimeoSessionManager
            .post("TryStartUpload",
                  parameters: params,
                  progress: nil,
                  success: { [weak self] (task, response) in
                    
                    if let strongSelf = self {
                        if let
                            response = response as? [String : AnyObject],
                            let successful = (response["Success"] as? NSNumber)?.boolValue {
                            
                            if successful {
                                // Try to getting the media part identifier and Vimeo url
                                // from the response.
                                if let dataPart = response["Data"] as? [String : AnyObject] {
                                    strongSelf.contentId = (dataPart["MediaPartId"] as? NSNumber)?.intValue
                                    strongSelf.vimeoStringURL = dataPart["uploadUrl"] as? String
                                }
                                
                                // Checking if all the values have been retrieved from WS.
                                if strongSelf.contentId == nil && strongSelf.vimeoStringURL == nil {
                                    let error = strongSelf.generateError(.missingDetachedMediaPart, withDescription: nil)
                                    strongSelf.manageError(error)
                                } else {
                                    // Notifying the delegate that the content identifier
                                    // has been received.
                                    strongSelf.completionQueue.addOperation { [weak self] in
                                        if let strongSelf = self {
                                            strongSelf.completionHandler?(strongSelf.contentId!, false)
                                        }
                                    }
                                    // Creating the task that will check if the video
                                    // must resume and from where.
                                    strongSelf.videoNeedsResume()
                                }
                            } else {
                                let missingMediaPartInfoError = strongSelf.generateError(.missingDetachedMediaPart, withDescription: nil)
                                strongSelf.manageError(missingMediaPartInfoError)
                            }
                        }
                    }
                }, failure:  { [weak self] (task : URLSessionTask?, error: Error) in
                    self?.manageError(error)
                })
        
        activeTask = retrieveVideoURL
    }
    
    // MARK: - Vimeo uploading
    
    /**
     Request to Vimeo the last video byte that has received, adding the resume
     logic to the upload.
     */
    fileprivate func videoNeedsResume() {
        guard let vimeoStringURL = vimeoStringURL else {
            // No URL available for the current media, something is wrong.
            manageError(generateError(.missingVimeoVideoUrl, withDescription: nil))
            return
        }
        
        do {
            // Creating the task used to verify the progress of the upload.
            let vimeoResumeCheckTask = try vimeoSessionManager
                .uploadProgressTask(vimeoStringURL) { [weak self] (bytesReceivedCount, error) in
                    
                    if let strongSelf = self {
                        if let lastByteReceived = bytesReceivedCount {
                            // Saving the count of bytes received by Vimeo to report
                            // correctly the status of the upload.
                            strongSelf.videoContentAlreadyReceivedByVimeo = Int64(lastByteReceived)
                            // Resuming the upload from the byte after the last
                            // received.
                            let firstByteToSend = lastByteReceived == 0 ? lastByteReceived : lastByteReceived + 1
                            strongSelf.uploadOnVimeo(resumingFrom: firstByteToSend)
                        } else {
                            let errorToReport: NSError
                            if error != nil {
                                errorToReport = error!
                            } else {
                                errorToReport = strongSelf.generateError(.genericError, withDescription: nil)
                            }
                            strongSelf.manageError(errorToReport)
                            strongSelf.reportUploadStopped(KErrorCode.genericError)
                        }
                    }
            }
            // Starting the task.
            vimeoResumeCheckTask.resume()
            activeTask = vimeoResumeCheckTask
        } catch let error as NSError {
            // Some error has occurred during the generation of the task.
            manageError(error)
            // Notifying the service that this upload is unrecoverable.
            reportUploadStopped(KErrorCode.uploadStopped)
        }
    }
    
    /**
     Start uploading the video on Vimeo.
     
     - parameter firstByte: the byte of the video that is expected by Vimeo to
     resume the upload.
     */
    fileprivate func uploadOnVimeo(resumingFrom firstByte: Int) {
        guard let vimeoStringURL = vimeoStringURL else {
            // No vimeo URL received for the current method.
            let error = generateError(.missingVimeoVideoUrl, withDescription: nil)
            manageError(error)
            return
        }
        
        do {
            // Creating the task to upload the video on Vimeo.
            let vimeoUploadTask = try vimeoSessionManager
                .uploadVideoTask(source: contentToUpload,
                                 destination: vimeoStringURL,
                                 startingAt: firstByte,
                                 progress: { [weak self] (progress) in
                                    
                                    self?.videoContentSendedBytes = progress.completedUnitCount
                }) { [weak self] (error) in
                    
                    if let strongSelf = self {
                        if let error = error {
                            if error.code == NSURLErrorTimedOut {
                                strongSelf.videoNeedsResume()
                            } else {
                                strongSelf.manageError(error)
                                strongSelf.reportUploadStopped(KErrorCode.genericError)
                            }
                        } else {
                            // The upload should be completed.
                            // Requesting the service to verify the status.
                            strongSelf.verifyCompletedUpload()
                        }
                    }
            }
            // Starting the upload task.
            vimeoUploadTask.resume()
            activeTask = vimeoUploadTask
        } catch let error as NSError {
            // Some error has occurred during the generation of the task.
            manageError(error)
            // Notifying the service that this upload is unrecoverable.
            reportUploadStopped(KErrorCode.uploadStopped)
        }
    }
    
    // MARK: - Notify completed upload
    
    /**
     Checking if the upload has finished.
     */
    fileprivate func verifyCompletedUpload() {
        guard let mediaPartId = contentId else {
            return
        }
        
        let uploadCompletedCallbackTask = krakeVimeoSessionManager
            .post("FinishUpload",
                  parameters: ["mediaPartId" : mediaPartId],
                  progress: nil,
                  success: { [weak self] (task, response) in
                    
                    if let strongSelf = self {
                        if let
                            response = response as? [String : AnyObject],
                            let successful = (response["Success"] as? NSNumber)?.boolValue {
                            
                            if successful {
                                strongSelf.completionQueue.addOperation { [weak self] in
                                    self?.completionHandler?(mediaPartId, true)
                                    self?.internalState = .completed
                                }
                            } else {
                                strongSelf.manageErrorOnAck(KrakeResponse(object: response))
                            }
                        }
                    }
                }, failure: { [weak self] (task, error) in
                    self?.manageError(error)
                })
        
        if uploadCompletedCallbackTask != nil {
            activeTask = uploadCompletedCallbackTask
        }
    }
    
    /**
     Handle the error received from FinishUpload call. Some error can be handled
     others are distructive.
     
     - parameter response: the response received from the service as JSON.
     */
    fileprivate func manageErrorOnAck(_ responseObject: KrakeResponse?) {
        if let response = responseObject {
            switch response.errorCode {
            case KResolutionAction.inProgress:
                // Getting the Vimeo URL to resume the upload.
                vimeoStringURL = (response.data as? [String : String])?["uploadUrl"]
                // The upload may resume.
                videoNeedsResume()
            case KResolutionAction.uploadNeverStarted:
                // No upload received by the WS for the current media.
                requestUploadInformation()
            case KResolutionAction.finishingErrors:
                // This error can be ignored.
                if let mediaPartId = contentId {
                    completionQueue.addOperation { [weak self] in
                        self?.completionHandler?(mediaPartId, true)
                        self?.internalState = .completed
                    }
                }
            default:
                // Unexpected error received, no operation can be performed
                // to upload the content.
                let error = NSError(domain: VimeoUploaderErrorDomain,
                                    code: response.errorCode,
                                    userInfo: [kCFErrorDescriptionKey as String: response.message])
                manageError(error)
            }
        }else{
            // Reporting a generic error.
            manageError(generateError(.genericError, withDescription: "Generic error".localizedString()))
        }
    }
    
    // MARK: - Upload stopped reporting
    
    /**
     Send a feedback to the WS to notify the stopping of the video upload.
     
     - parameter reason: the code that refers to the reason of the stopping.
     See UploadStoppedErrorCodes for more information.
     */
    fileprivate func reportUploadStopped(_ reason: Int) {
        guard let vimeoVideoURL = vimeoStringURL, let mediaId = contentId else {
            return
        }
        
        let requestBody = [ "Data" : [ "id" : mediaId, "uploadUrl" : vimeoVideoURL ], "ErrorCode" : reason ] as [String : Any]
        let _ = errorSessionManager
            .post("ErrorHandler",
                  parameters: requestBody,
                  progress: nil,
                  success: nil,
                  failure: nil)
    }
    
    // MARK: - Error reporting
    
    /**
     Change the internal state of the task to completed and save the error, to
     inform the task creator that this task has failed.
     
     - parameter error: the NSError received.
     */
    fileprivate func manageError(_ error: Error?) {
        internalState = .completed
        internalError = error
    }
    
    /**
     Wraps an error code received during the handshake in a uniformed manner.
     
     - parameter code:        the code received by the service.
     - parameter description: an optional description that will be available into
     userInfo of the error.
     
     - returns: the NSError representing the error received by the service.
     */
    fileprivate func generateError(_ code: VimeoUploaderErrorCode, withDescription description: String?) -> NSError {
        var userInfo: [String: Any]? = nil
        if let errorDescription = description {
            userInfo = [kCFErrorDescriptionKey as String : errorDescription]
        }
        
        let error = NSError(domain: VimeoUploaderErrorDomain,
                            code: code.rawValue,
                            userInfo: userInfo)
        return error
    }
    
    // MARK: - Task statuses
    
    override var state: URLSessionTask.State {
        return internalState
    }
    
    override var error: Error? {
        return internalError
    }
    
    override var countOfBytesExpectedToSend: Int64 {
        return Int64(contentToUpload.bytes.count)
    }
    
    override var countOfBytesExpectedToReceive: Int64 {
        return NSURLSessionTransferSizeUnknown
    }
    
    override var countOfBytesSent: Int64 {
        return videoContentSendedBytes + videoContentAlreadyReceivedByVimeo
    }
    
    override var countOfBytesReceived: Int64 {
        return activeTask?.countOfBytesReceived ?? 0
    }
    
    override var currentRequest: URLRequest? {
        return activeTask?.currentRequest
    }
    
    // MARK: - NSURLSessionTask operations
    
    override func resume() {
        if internalState != .completed {
            internalState = .running
            // Starting the task that was active.
            if let activeTask = activeTask {
                if activeTask.state != .running {
                    activeTask.resume()
                }
            } else {
                // Starting the first task of the handshake.
                if contentId == nil {
                    // Starting a new request for the request media.
                    requestUploadInformation()
                } else {
                    // Verifying if the media was successfuly uploaded.
                    verifyCompletedUpload()
                }
            }
        }
    }
    
    override func suspend() {
        if internalState != .completed {
            internalState = .suspended
            // Suspending the task that is active.
            if let activeTask = activeTask {
                if activeTask.state != .suspended {
                    activeTask.suspend()
                }
                // Reporting that the upload has been suspended and the
                // upload may be resumed in the future.
                reportUploadStopped(KErrorCode.uploadMayResume)
            }
        }
    }
    
    override func cancel() {
        if internalState != .completed {
            internalState = .canceling
            // Cancelling the active task.
            if let activeTask = activeTask {
                if activeTask.state != .canceling {
                    activeTask.cancel()
                }
                // Reporting that the upload has been cancelled and the
                // upload will not resume.
                reportUploadStopped(KErrorCode.uploadMayResume)
            }
        }
    }
    
    // MARK: - Debug utilities
    
    override var description: String {
        return "Vimeo URL: \(vimeoStringURL ?? "nil")"
    }
    
    override var debugDescription: String {
        return "{" + "\n" +
            "\t" + "Vimeo URL: \(vimeoStringURL ?? "nil")" + "\n" +
            "\t" + "Media part id: \(contentId ??? "nil")" + "\n" +
            "\t" + "Video local path: \(videoURL)" + "\n" +
        "}"
    }
    
}
