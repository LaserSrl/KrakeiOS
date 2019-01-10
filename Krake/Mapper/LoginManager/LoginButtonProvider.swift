//
//  LoginButtonProvider.swift
//  Pods
//
//  Created by joel on 01/06/17.
//
//

import Foundation

public typealias AuthProviderBlock = (_ loginSuccess: Bool, _ params: [String: String]?, _ error: Error?) -> Void

protocol LoginButtonManager {
    func generateButton(_ completionBlock: AuthProviderBlock?) -> UIBarButtonItem
}
