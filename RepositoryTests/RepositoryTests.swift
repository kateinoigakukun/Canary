//
//  RepositoryTests.swift
//  RepositoryTests
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import XCTest
import OAuthSwift
@testable import Repository

class MockRepository: RepositoryType {
    var client: ClientType

    init(client: ClientType) {
        self.client = client
    }
}

class RepositoryTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testTimelineRequest() {
        let client = OAuthSwiftClient(
            consumerKey: Secret.shared.consumerKey,
            consumerSecret: Secret.shared.consumerSecret,
            oauthToken: Secret.shared.oauthToken,
            oauthTokenSecret: Secret.shared.oauthTokenSecret,
            version: .oauth1
        )
        let repository = MockRepository(client: client)
        let timelineRequest = HomeTimelineRequest()
        switch repository.send(timelineRequest).first()! {
        case .success(let timeline):
            XCTAssertFalse(timeline.isEmpty)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
