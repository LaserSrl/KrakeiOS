//
//  VimeoUploaderError.swift
//  Pods
//
//  Created by Marco Zanino on 22/07/16.
//
//

import Foundation

public let VimeoUploaderErrorDomain: String = "VimeoVideoUploadError"

public enum VimeoUploaderErrorCode: Int {
    case genericError = -1001
    case missingVimeoVideoUrl = -1002
    case missingDetachedMediaPart = -1003
}
