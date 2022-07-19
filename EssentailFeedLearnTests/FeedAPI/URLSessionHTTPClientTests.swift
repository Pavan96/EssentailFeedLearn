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
    
    func test_getFromURL_failsOnRequestError() {
        
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "htpp://a-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, respone: nil, error: error)
        
        let sut = URLSessionHTTPClient()

        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
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
        URLProtocolStub.stoptInterceptingRequests()
    }
    
    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data? , respone: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: respone, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stoptInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
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


