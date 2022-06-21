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
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let aUrl = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: aUrl)
        
        sut.load(completion: { _ in })
        
        XCTAssertNotNil(client.requestedURLs)
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let aUrl = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: aUrl)
        
        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [aUrl, aUrl])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var captureErrors = [RemoetFeedLoader.Error]()
        sut.load { error in
            captureErrors.append(error)
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(captureErrors, [.connectivity])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoetFeedLoader, client: HTTPClientSpy) {
       let client = HTTPClientSpy()
       let sut = RemoetFeedLoader(client: client, url: url)
       return (sut, client	)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{ $0.url }
        }

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
