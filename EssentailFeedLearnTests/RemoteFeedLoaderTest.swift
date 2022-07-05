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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidaJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidaJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
       
        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(),
                                          imageURL:  URL(string: "http://a-image.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description", location: "location",
                             imageURL: URL(string: "http://a-url.com")!)
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            
            let json = makeItemJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoetFeedLoader, client: HTTPClientSpy) {
       let client = HTTPClientSpy()
       let sut = RemoetFeedLoader(client: client, url: url)
       trackMemoryLeak(sut, file: file, line: line)
       trackMemoryLeak(client, file: file, line: line)
       return (sut, client)
    }
    
    private func trackMemoryLeak(_ instance: AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
           XCTAssertNil(instance, "Instance should have been deallcocated potential memory leak.", file: file, line: line)
        }
    }
    
    // Factory method to create the item
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, location: location, description: description, imageURL: imageURL)
        let itemJSON: [String: Any] = ["id" : item.id.uuidString,
                         "description": item.description,
                         "location" : item.location,
                                       "image": item.imageURL.absoluteString].compactMapValues{ $0 }
        return (item, itemJSON)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoetFeedLoader,      toCompleteWith result: RemoetFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var captureResults = [RemoetFeedLoader.Result]()
        sut.load { result in
            captureResults.append(result)
        }
        action()
        XCTAssertEqual(captureResults, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
