//
//  StreamingProvider.swift
//  Krake
//
//  Created by Marco Zanino on 18/07/16.
//
//

import Foundation

enum KStreamingProviderErrors: Error {
    case unknownProvider, malformedProviderString
}

public protocol KStreamingProviderSupplier {
    func register(streamingProvider provider: KStreamingProvider)
    func getStreamingProvider(fromSource string: String) throws -> KStreamingProvider
}

public protocol KStreamingProvider {
    var name: String { get }
    func retrieveVideoURL(from videoString: String) -> String?
}

//Mark: - Deprecated

@available(*, deprecated, renamed: "KStreamingProviderErrors")
enum StreamingProviderErrors: Error {
    case unknownProvider, malformedProviderString
}

@available(*, deprecated, renamed: "KStreamingProviderSupplier")
public protocol StreamingProviderSupplier: KStreamingProviderSupplier {
    
}

@available(*, deprecated, renamed: "KStreamingProvider")
public protocol StreamingProvider: KStreamingProvider {
    
}
