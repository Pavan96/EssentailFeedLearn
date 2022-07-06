//
//  FeedLoader.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 09/06/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

