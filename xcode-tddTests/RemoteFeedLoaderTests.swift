//
//  RemoteFeedLoaderTests.swift
//  xcode-tddTests
//
//  Created by Akshay Gajarlawar on 13/06/21.
//

import XCTest
import xcode_tdd

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_ , client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    /*
    //Three ways of dependency injection:
     
    1. Constructor Injection
    let sut = RemoteFeedLoader(client: client)
     
    2. Property Injection
    sut.client = client
     
    3. Method injection
    sut.load(client: client)
   
    
    func test_load_requestData() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        sut.client = client
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    */
    
    /*
    //Singleton
    func test_load_requestData() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    */
    
    func test_load_requestsDataFromURL() {
        let url = URL.init(string: "https://some-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load { _ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL.init(string: "https://some-url.com")!
        let (sut , client) = makeSUT(url: url)
        sut.load  { _ in}
        sut.load  { _ in}
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_deliverErrorOnClientError() {
        let url = URL.init(string: "https://some-url.com")!
        let (sut , client) = makeSUT(url: url)
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError.init(domain: "TestError", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_deliverErrorOnNonStatusCode200() {
        let url = URL.init(string: "https://some-url.com")!
        let (sut , client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { (index, code) in
            
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load { capturedErrors.append($0) }
            
            client.complete(withErrorCode: 400, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }        
    }
    
    private func makeSUT(url: URL = URL.init(string: "https://default-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader.init(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages: [(url: URL, completion:(HTTPClientResult) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withErrorCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse.init(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            messages[index].completion(.success(response!))
        }
    }
    
}
