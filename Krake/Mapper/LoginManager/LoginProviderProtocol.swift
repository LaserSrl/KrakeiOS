//
//  LoginButtonProvider.swift
//  Pods
//
//  Created by joel on 01/06/17.
//
//

import Foundation

public typealias AuthProviderBlock = (_ loginSuccess: Bool, _ params: [String: String]?, _ error: Error?) -> Void

@objc public enum KLoginStackPosition: Int {
    case horizontal
    case vertical
}

@objc public protocol KLoginProviderProtocol {
    static var shared: KLoginProviderProtocol {get}
    func getLoginView() -> UIView
    func loginStackPosition() -> KLoginStackPosition
}

