//
//  RemoteFeedLoader.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 21/06/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoetFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}


