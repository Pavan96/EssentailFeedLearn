//
//  URLSessionHTTPClient.swift
//  EssentailFeedLearn
//
//  Created by Pavan More on 21/07/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared){
        self.session = session
    }
    
    struct UnexpectedRepresentationError: Error { }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedRepresentationError()))
            }
        }.resume()
    }
}
