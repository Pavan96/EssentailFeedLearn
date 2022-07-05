//
//  FeedItemMapper.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 05/07/22.
//

import Foundation

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map{ $0.item }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let location: String?
        let description: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, location: location, description: description, imageURL: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoetFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root =  try? JSONDecoder().decode(Root.self, from: data) else {
              return .failure(.invalidData)
        }
        return .success(root.feed)
    }
}
