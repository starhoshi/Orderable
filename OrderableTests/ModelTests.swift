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

    func testSaveOrder() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "save order")

        let user = SampleUser()
        let order = SampleOrder()
        order.user.set(user)
        order.amount = 1000
        order.paidDate = Date(timeIntervalSince1970: 111111)
        order.expirationDate = Date(timeIntervalSince1970: 33333)
        order.currency = "jpy"
        order.paymentStatus = .created
        order.stripe = SampleStripe()
        order.stripe?.customerID = "cus"
        order.stripe?.cardID = "card"
        order.stripe?.chargeID = "charge"

        order.save { ref, error in
            SampleOrder.get(ref!.documentID, block: { savedOrder, error in
                XCTAssertNotNil(savedOrder)
                XCTAssertEqual(savedOrder?.user.id, user.id)
                XCTAssertEqual(savedOrder?.amount, order.amount)
                XCTAssertEqual(savedOrder?.paidDate?.timeIntervalSince1970, order.paidDate?.timeIntervalSince1970)
                XCTAssertEqual(savedOrder?.expirationDate?.timeIntervalSince1970, order.expirationDate?.timeIntervalSince1970)
                XCTAssertEqual(savedOrder?.currency, order.currency)
                XCTAssertEqual(savedOrder?.paymentStatus, order.paymentStatus)
                XCTAssertEqual(savedOrder?.stripe?.customerID, order.stripe?.customerID)
                XCTAssertEqual(savedOrder?.stripe?.chargeID, order.stripe?.chargeID)
                XCTAssertEqual(savedOrder?.stripe?.cardID, order.stripe?.cardID)
                expectation.fulfill()
            })
        }

        wait(for: [expectation], timeout: 10)
    }

    func testUpdaterder() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "update order")

        let user = SampleUser()
        let order = SampleOrder()
        order.user.set(user)
        order.amount = 1000
        order.paidDate = Date(timeIntervalSince1970: 1)
        order.expirationDate = Date(timeIntervalSince1970: 109865433)
        order.currency = "jpy"
        order.paymentStatus = .unknown
        let stripe = SampleStripe()
        stripe.customerID = "cus"
        stripe.cardID = "card"
        stripe.chargeID = "charge"
        order.stripe = stripe

        order.save { ref, error in
            order.amount = 111111
            order.paidDate = Date(timeIntervalSince1970: 3456)
            order.expirationDate = Date(timeIntervalSince1970: 9976)
            order.currency = "us"
            order.paymentStatus = .created
            let stripe = SampleStripe()
            stripe.customerID = "new_cus"
            stripe.cardID = "new_card"
            stripe.chargeID = "new_charge"
            order.stripe = stripe

            order.update { error in
                SampleOrder.get(ref!.documentID, block: { updatedOrder, error in
                    XCTAssertNotNil(updatedOrder)
                    XCTAssertEqual(updatedOrder?.amount, order.amount)
                    XCTAssertEqual(updatedOrder?.paidDate, order.paidDate)
                    XCTAssertEqual(updatedOrder?.paidDate?.timeIntervalSince1970, order.paidDate?.timeIntervalSince1970)
                    XCTAssertEqual(updatedOrder?.expirationDate?.timeIntervalSince1970, order.expirationDate?.timeIntervalSince1970)
                    XCTAssertEqual(updatedOrder?.currency, order.currency)
                    XCTAssertEqual(updatedOrder?.paymentStatus, order.paymentStatus)
                    XCTAssertEqual(updatedOrder?.paymentStatus, order.paymentStatus)
                    XCTAssertEqual(updatedOrder?.stripe?.customerID, order.stripe?.customerID)
                    XCTAssertEqual(updatedOrder?.stripe?.chargeID, order.stripe?.chargeID)
                    XCTAssertEqual(updatedOrder?.stripe?.cardID, order.stripe?.cardID)
                    expectation.fulfill()
                })
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}
