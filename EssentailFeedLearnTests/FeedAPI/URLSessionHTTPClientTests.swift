//
//  URLSessionHTTPClientTests.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 13/07/22.
//

import XCTest
import EssentailFeedLearn

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession){
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "htpp://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, task: task)
        sut.get(from: url) { _ in }
     
        XCTAssertEqual(task.resumesCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "htpp://a-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "Wiat for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError, error)
                
            default:
                XCTFail("Expected failure with \(error) but got \(result)")
            }
            
            exp.fulfill()
        }
      
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find the error for given \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumesCount = 0
        
        override func resume() {
            resumesCount += 1
        }
    }

}
