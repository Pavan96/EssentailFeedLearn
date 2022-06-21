//
//  RemoteFeedLoaderTest.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 09/06/22.
//

import XCTest
import EssentailFeedLearn

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requesteURL)
    }
    
    func test_load_requestDataFromURL() {
        let aUrl = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: aUrl)
        
        sut.load()
        
        XCTAssertNotNil(client.requesteURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoetFeedLoader, client: HTTPClientSpy) {
       let client = HTTPClientSpy()
       let sut = RemoetFeedLoader(client: client, url: url)
       return (sut, client	)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requesteURL: URL?

        func get(from url: URL) {
            requesteURL = url
        }
    }
}
