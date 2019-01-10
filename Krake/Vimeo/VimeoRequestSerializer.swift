//
//  VimeoRequestSerializer.swift
//  VimeoUpload
//
//  Created by Hanssen, Alfie on 10/16/15.
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
import AFNetworking

class VimeoRequestSerializer: AFJSONRequestSerializer
{
    fileprivate static let AcceptHeaderKey = "Accept"
    fileprivate static let AuthorizationHeaderKey = "Authorization"
    
    // MARK: 
    
    fileprivate var authTokenBlock: AuthTokenBlock
    
    // MARK: - Initialization
    
    init(authTokenBlock: @escaping AuthTokenBlock, version: String = VimeoDefaultAPIVersionString)
    {
        self.authTokenBlock = authTokenBlock
        
        super.init()
        
        self.setValue("application/vnd.vimeo.*+json; version=\(version)", forHTTPHeaderField: type(of: self).AcceptHeaderKey)
        self.writingOptions = .prettyPrinted
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    override func request(withMethod method: String, urlString URLString: String, parameters: Any?, error: NSErrorPointer) -> NSMutableURLRequest {
        var request = super.request(withMethod: method, urlString: URLString, parameters: parameters, error: error)
        self.setAuthorizationHeader(request: &request)
        return request
    }
    
    override func request(bySerializingRequest request: URLRequest, withParameters parameters: Any?, error: NSErrorPointer) -> URLRequest? {
        if var request = super.request(bySerializingRequest: request, withParameters: parameters, error: error)
        {
            self.setAuthorizationHeader(request: &request)
            return request
        }
        
        return nil
    }
    
    override func request(withMultipartForm request: URLRequest, writingStreamContentsToFile fileURL: URL, completionHandler handler: ((Error?) -> Void)? = nil) -> NSMutableURLRequest {
        var request = super.request(withMultipartForm: request, writingStreamContentsToFile: fileURL, completionHandler: handler)
        self.setAuthorizationHeader(request: &request)
        return request
    }
    
    // MARK: Private API
    
    fileprivate func setAuthorizationHeader(request: inout NSMutableURLRequest)
    {
        if let token = self.authTokenBlock()
        {
            let value = "Bearer \(token)"
            request.setValue(value, forHTTPHeaderField: type(of: self).AuthorizationHeaderKey)
        }
    }
    
    fileprivate func setAuthorizationHeader(request: inout URLRequest)
    {
        if let token = self.authTokenBlock()
        {
            let value = "Bearer \(token)"
            request.setValue(value, forHTTPHeaderField: type(of: self).AuthorizationHeaderKey)
        }
    }
}
