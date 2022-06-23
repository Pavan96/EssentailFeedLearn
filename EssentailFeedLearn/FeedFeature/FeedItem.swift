//
//  FeedItem.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 08/06/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let location: String?
    let description: String?
    let imageURL: URL?
}
