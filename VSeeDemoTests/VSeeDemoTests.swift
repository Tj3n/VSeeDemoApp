//
//  VSeeDemoTests.swift
//  VSeeDemoTests
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import XCTest
import Moya
import RealmSwift
@testable import VSeeDemo

class VSeeDemoTests: XCTestCase {
    
    var provider = MoyaProvider<NewsTarget>(stubClosure: MoyaProvider.immediatelyStub)
    lazy var viewModel: MasterViewModel = MasterViewModel(delegate: self, newsClient: NewsClient(provider: provider, latestDate: Date()))
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //Check parser
    func testMock() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = self.expectation(description: "Success")
        
        let provider = MoyaProvider<NewsTarget>(stubClosure: MoyaProvider.immediatelyStub)
        provider.request(.fetchTopHeadlines) { (result) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(_):
                XCTFail("Error parsing")
            }
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    private var updateExpectation: XCTestExpectation!
    //Check if update is called
    func testViewModel() {
        updateExpectation = self.expectation(description: "updateExpectation")
        viewModel.load()
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    private var updateFailedExpectation: XCTestExpectation!
    //Check if failure is called
    func testViewModelFailure() {
        let serverErrorEndpointClosure = { (target: NewsTarget) -> Endpoint in
          return Endpoint(url: URL(target: target).absoluteString,
                          sampleResponseClosure: { .networkResponse(500 , Data()) },
                          method: target.method,
                          task: target.task,
                          httpHeaderFields: target.headers)
        }
        let serverErrorProvider = MoyaProvider<NewsTarget>(endpointClosure: serverErrorEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        provider = serverErrorProvider
        updateExpectation = self.expectation(description: "updateExpectation")
        updateFailedExpectation = expectation(description: "updateFailedExpectation")
        viewModel.load()
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension VSeeDemoTests: MasterViewModelDelegate {
    func dbDidChange(changes: RealmCollectionChange<Results<ArticleRealm>>) {
        updateExpectation.fulfill()
    }
    
    func onError(_ error: Error) {
        updateFailedExpectation.fulfill()
    }
    
    
}
