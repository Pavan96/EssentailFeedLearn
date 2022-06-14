//
//  RemoteFeedLoaderTest.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 09/06/22.
//

import XCTest

class RemoetFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requesteURL: URL?

    func get(from url: URL) {
        requesteURL = url
    }
}

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let aUrl = URL(string: "https://a-given-url")
        let client = HTTPClientSpy()
        let _ = RemoetFeedLoader(client: client, url: aUrl!)
        XCTAssertNil(client.requesteURL)
    }
    
    func test_load_requestDataFromURL() {
        let aUrl = URL(string: "https://a-given-url")
        let client = HTTPClientSpy()
        let sut = RemoetFeedLoader(client: client, url: aUrl!)
        
        sut.load()
        
        XCTAssertNotNil(client.requesteURL)
    }
}
