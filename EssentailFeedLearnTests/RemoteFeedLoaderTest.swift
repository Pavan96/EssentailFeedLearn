//
//  RemoteFeedLoaderTest.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 09/06/22.
//

import XCTest

class RemoetFeedLoader {
    func load() {
        HTTPClient.shared.requesteURL = URL(string: "https://string-url")
    }
}

class HTTPClient {
    
    static let shared: HTTPClient = HTTPClient()
    
    private init() { }
    
    var requesteURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        let _ = RemoetFeedLoader()
        XCTAssertNil(client.requesteURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoetFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requesteURL)
    }
}
