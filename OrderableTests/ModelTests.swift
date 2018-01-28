//
//  ModelTests.swift
//  OrderableTests
//
//  Created by kensuke-hoshikawa on 2018/01/28.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import XCTest
import Orderable
import FirebaseCore

class ModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSaveUser() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "save user")

        let user = User()
        user.stripeCustomerID = "cus_test"

        user.save { ref, error in
            User.get(ref!.documentID, block: { savedUser, error in
                XCTAssertNotNil(savedUser)
                XCTAssertEqual(savedUser?.stripeCustomerID, "cus_test")
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 10)
    }

    func testUpdateUser() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "update user")

        let user = User()
        user.stripeCustomerID = "cus_test_updated"

        user.save { ref, error in
            user.update { error in
                User.get(ref!.documentID, block: { updatedUser, error in
                    XCTAssertNotNil(updatedUser)
                    XCTAssertEqual(updatedUser?.stripeCustomerID, "cus_test_updated")
                    expectation.fulfill()
                })
            }
        }
        wait(for: [expectation], timeout: 10)
    }
}
