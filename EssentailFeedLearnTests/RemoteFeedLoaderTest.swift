//
//  RemoteFeedLoaderTest.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 09/06/22.
//

import XCTest

class RemoetFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://string-url")!)
    }
}

class HTTPClient {
    
    static var shared: HTTPClient = HTTPClient()
    
    func get(from url: URL) {
    }
}

class HTTPClientSpy: HTTPClient {
    var requesteURL: URL?

    override func get(from url: URL) {
        requesteURL = url
    }
}

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let _ = RemoetFeedLoader()
        XCTAssertNil(client.requesteURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoetFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requesteURL)
    }
}
