//
//  HTTPClient.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 05/07/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
