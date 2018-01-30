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

        let user = User()
        let order = Order()
        order.user.set(user)
        order.amount = 1000
        order.paidDate = 10
        order.expirationDate = 100
        order.stripeChargeID = "charge"
        order.currency = "jpy"
        order.paymentStatus = .created
        order.stripeCardID = "card_id"
        order.stripeCustomerID = "cus_id"
        order.paymentAgencyType = .stripe

        order.save { ref, error in
            Order.get(ref!.documentID, block: { savedOrder, error in
                XCTAssertNotNil(savedOrder)
                XCTAssertEqual(savedOrder?.user.id, user.id)
                XCTAssertEqual(savedOrder?.stripeCardID, order.stripeCardID)
                XCTAssertEqual(savedOrder?.amount, order.amount)
                XCTAssertEqual(savedOrder?.paidDate, order.paidDate)
                XCTAssertEqual(savedOrder?.expirationDate, order.expirationDate)
                XCTAssertEqual(savedOrder?.stripeChargeID, order.stripeChargeID)
                XCTAssertEqual(savedOrder?.currency, order.currency)
                XCTAssertEqual(savedOrder?.paymentStatus, order.paymentStatus)
                XCTAssertEqual(savedOrder?.stripeCustomerID, order.stripeCustomerID)
                XCTAssertEqual(savedOrder?.paymentAgencyType, order.paymentAgencyType)
                expectation.fulfill()
            })
        }

        wait(for: [expectation], timeout: 10)
    }

    func testUpdaterder() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "update order")

        let user = User()
        let order = Order()
        order.user.set(user)
        order.stripeCardID = "card_id"
        order.amount = 1000
        order.paidDate = 10
        order.expirationDate = 100
        order.stripeChargeID = "charge"
        order.currency = "jpy"
        order.paymentStatus = .unknown
        order.stripeCustomerID = "cus_id"
        order.paymentAgencyType = .stripe

        order.save { ref, error in
            order.stripeCardID = "new_card_id"
            order.amount = 111111
            order.paidDate = 1234
            order.expirationDate = 5678
            order.stripeChargeID = "new_charge"
            order.currency = "us"
            order.paymentStatus = .created
            order.stripeCustomerID = "new_cus_id"
            order.paymentAgencyType = .unknown

            order.update { error in
                Order.get(ref!.documentID, block: { updatedOrder, error in
                    XCTAssertNotNil(updatedOrder)
                    XCTAssertEqual(updatedOrder?.stripeCardID, order.stripeCardID)
                    XCTAssertEqual(updatedOrder?.amount, order.amount)
                    XCTAssertEqual(updatedOrder?.paidDate, order.paidDate)
                    XCTAssertEqual(updatedOrder?.expirationDate, order.expirationDate)
                    XCTAssertEqual(updatedOrder?.stripeChargeID, order.stripeChargeID)
                    XCTAssertEqual(updatedOrder?.currency, order.currency)
                    XCTAssertEqual(updatedOrder?.paymentStatus, order.paymentStatus)
                    XCTAssertEqual(updatedOrder?.stripeCustomerID, order.stripeCustomerID)
                    XCTAssertEqual(updatedOrder?.paymentAgencyType, order.paymentAgencyType)
                    expectation.fulfill()
                })
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    // TODO: order.status is not updated
//    func testOrderPay() {
//        let expectation: XCTestExpectation = XCTestExpectation(description: "update order")
//
//        let order = Order()
//        order.status = OrderStatus.created.rawValue
//
//        order.save { ref, error in
//            order.pay { error in
//                Order.get(ref!.documentID, block: { updatedOrder, error in
//                    XCTAssertNotNil(updatedOrder)
//                    XCTAssertEqual(updatedOrder?.status, OrderStatus.paymentRequested.rawValue)
//                    expectation.fulfill()
//                })
//            }
//        }
//
//        wait(for: [expectation], timeout: 10)
//    }
}
