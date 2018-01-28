//
//  OrderableTests.swift
//  OrderableTests
//
//  Created by kensuke-hoshikawa on 2018/01/28.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import XCTest
import Orderable
import FirebaseCore

class OrderableTests: XCTestCase {
    var user: User?
    var shop: Shop?
    var product: Product?
    var sku: SKU?
    var order: Order?
    var orderShop: OrderShop?
    var orderSKU: OrderSKU?

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
        let expectation: XCTestExpectation = XCTestExpectation(description: "save user")

        func fulfill() {
            if user != nil, shop != nil, product != nil, sku != nil, order != nil, orderShop != nil, orderSKU != nil {
                expectation.fulfill()
            }
        }

        let newUser = User()
        newUser.stripeCustomerID = "cus_test"
        newUser.save { [weak self] ref, error in
            self?.user = newUser
            fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    override func tearDown() {
        super.tearDown()

        user = nil
        shop = nil
        product = nil
        sku = nil
        order = nil
        orderShop = nil
        orderSKU = nil
    }
}
