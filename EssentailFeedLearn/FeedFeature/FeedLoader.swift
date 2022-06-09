//
//  FeedLoader.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 09/06/22.
//

import Foundation

enum LoadFeedResutt {
    case success([FeedItem])
    case erro(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResutt) -> Void)
}

