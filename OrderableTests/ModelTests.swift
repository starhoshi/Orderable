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
        user.stripeCustomerID = "cus_test"

        user.save { ref, error in
            user.stripeCustomerID = "cus_test_updated"
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

    func testSaveOrder() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "save order")

        let user = User()
        let order = Order()
        order.user.set(user)
        order.stripeCardID = "card_id"
        order.amount = 1000
        order.paidDate = 10
        order.expirationDate = 100
        order.status = .created
        order.stripeChargeID = "charge"
        order.currency = "jpy"

        order.save { ref, error in
            Order.get(ref!.documentID, block: { savedOrder, error in
                XCTAssertNotNil(savedOrder)
                XCTAssertEqual(savedOrder?.user.id, user.id)
                XCTAssertEqual(savedOrder?.stripeCardID, "card_id")
                XCTAssertEqual(savedOrder?.amount, 1000)
                XCTAssertEqual(savedOrder?.paidDate, 10)
                XCTAssertEqual(savedOrder?.expirationDate, 100)
                XCTAssertEqual(savedOrder?.status, .created)
                XCTAssertEqual(savedOrder?.stripeChargeID, "charge")
                XCTAssertEqual(savedOrder?.currency, "jpy")
                expectation.fulfill()
            })
        }

        wait(for: [expectation], timeout: 10)
    }
}
