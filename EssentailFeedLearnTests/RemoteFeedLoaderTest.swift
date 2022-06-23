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
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidaJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidaJSON)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoetFeedLoader, client: HTTPClientSpy) {
       let client = HTTPClientSpy()
       let sut = RemoetFeedLoader(client: client, url: url)
       return (sut, client	)
    }
    
    private func expect(_ sut: RemoetFeedLoader,      toCompleteWithError error: RemoetFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var captureResults = [RemoetFeedLoader.Result]()
        sut.load { error in
            captureResults.append(error)
        }
        action()
        XCTAssertEqual(captureResults, [.failure(error)], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{ $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
