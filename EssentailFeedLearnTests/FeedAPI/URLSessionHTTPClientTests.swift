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
    
    init(session: URLSession = .shared){
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
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stoptInterceptingRequests()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        
        let url = URL(string: "htpp://a-url.com")!
        let exp = expectation(description: "Wait for completion")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, respone: nil, error: error)
        

        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
                
            default:
                XCTFail("Expected failure with \(error) but got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "htpp://a-url.com")!
    }
    
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data? , respone: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: respone, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stoptInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let erorr = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: erorr)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}


