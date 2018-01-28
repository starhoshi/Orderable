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
import Pring

class OrderableTests: XCTestCase {
    var disposer: Disposer<Order>?

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
        let expectation: XCTestExpectation = XCTestExpectation(description: "order test")

        func fulfill() {
            if user != nil, shop != nil, product != nil, sku != nil, order != nil, orderShop != nil, orderSKU != nil {
                order?.orderSKUs.insert(orderSKU!)
                order?.update { [weak self] orderError in
                    self?.orderShop?.orderSKUs.insert(self!.orderSKU!)
                    self?.orderShop?.update { orderShopError in
                        if orderError == nil, orderShopError == nil { expectation.fulfill() }
                    }
                }
            }
        }

        let newUser = User()
        newUser.save { [weak self] _, _ in
            self?.user = newUser; fulfill()
        }
        let newShop = Shop()
        newShop.save { [weak self] _, _ in
            self?.shop = newShop; fulfill()
        }
        let newProduct = Product()
        newProduct.save { [weak self] _, _ in
            self?.product = newProduct; fulfill()
        }
        let newSKU = SKU()
        newSKU.save { [weak self] _, _ in
            self?.sku = newSKU; fulfill()
        }
        let newOrder = Order()
        newOrder.user.set(newUser)
        newOrder.amount = 1000
        newOrder.save { [weak self] _, _ in
            self?.order = newOrder; fulfill()
        }
        let newOrderShop = OrderShop()
        newOrderShop.order.set(newOrder)
        newOrderShop.user.set(newUser)
        newOrderShop.save { [weak self] _, _ in
            self?.orderShop = newOrderShop; fulfill()
        }
        let newOrderSKU = OrderSKU()
        newOrderSKU.sku.set(newSKU)
        newOrderSKU.shop.set(newShop)
        newOrderSKU.snapshotSKU = newSKU
        newOrderSKU.snapshotProduct = newProduct
        newOrderSKU.save { [weak self] _, _ in
            self?.orderSKU = newOrderSKU; fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    override func tearDown() {
        super.tearDown()
        disposer = nil
        user = nil
        shop = nil
        product = nil
        sku = nil
        order = nil
        orderShop = nil
        orderSKU = nil
    }

    func testPayOrder() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "pay order")

        order?.status = OrderStatus.paymentRequested.rawValue
        order?.update()
        disposer = Order.listen(order!.id) { o, e in
            if let o = o, o.stripeChargeID != nil {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 20)
    }
}

