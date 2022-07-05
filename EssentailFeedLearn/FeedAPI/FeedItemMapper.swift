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
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoetFeedLoader.Error.invalidData
        }
        
        let root =  try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
