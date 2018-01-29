//
//  Model.swift
//  Orderable
//
//  Created by kensuke-hoshikawa on 2018/01/28.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import Foundation
import Pring
import Orderable

@objcMembers
public class User: Object, UserProtocol {
    public dynamic var stripeCustomerID: String? = "cus_CC65RZ8Gf6zi7V"
}

@objcMembers
public class Shop: Object, ShopProtocol {
    public dynamic var name: String? = "shop_name"
    public dynamic var isActive: Bool = true
    public dynamic var freePostageMinimunPrice: Int = -1
}

@objcMembers
public class Product: Object, ProductProtocol {
    public dynamic var name: String? = "product_name"
}

@objcMembers
public class SKU: Object, SKUProtocol {
    public dynamic var price: Int = 100
    public dynamic var stockType: StockType = .finite
    public dynamic var stock: Int = 100
    public dynamic var isPublished: Bool = true
    public dynamic var isActive: Bool = true
}

@objcMembers
class Order: Object, OrderProtocol {
    typealias OrderableUser = User
    typealias OrderableOrderSKU = OrderSKU

    dynamic var user: Reference<OrderableUser> = .init()

    /// ストライプに登録したカード情報。このカードIDで決済を行う
    dynamic var stripeCardID: String? = "card_1BnhthKZcOra3JxsKaxABsRj"

    /// 総計
    dynamic var amount: Int = 0

    /// 支払いが行われた日時
    dynamic var paidDate: TimeInterval = 0

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    dynamic var expirationDate: TimeInterval = 0
    dynamic var stripeChargeID: String? = nil
    dynamic var currency: String? = "jpy"
    dynamic var status: Int = OrderStatus.created.rawValue
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []

    /// for Komerco
    dynamic var skuPriceSum: Int = 0
    dynamic var postage: Int = 0
    dynamic var prefectureID: Int = 0
    dynamic var regionID: Int = 0
}

@objcMembers
class OrderShop: Object, OrderShopProtocol {
    typealias OrderableUser = User
    typealias OrderableOrder = Order
    typealias OrderableOrderSKU = OrderSKU

    dynamic var order: Reference<OrderableOrder> = .init()

    /// 購入された商品
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []

    /// 配送ステータス
    dynamic var status: Int = OrderShopStatus.created.rawValue

    /// 冗長化
    dynamic var user: Reference<OrderableUser> = .init()
}

@objcMembers
class OrderSKU: Object, OrderSKUProtocol {
    typealias OrderableSKU = SKU
    typealias OrderableShop = Shop

    dynamic var snapshotSKU: SKUProtocol?
    dynamic var snapshotProduct: ProductProtocol?
    dynamic var quantity: Int = 1
    dynamic var sku: Reference<OrderableSKU> = .init()
    dynamic var shop: Reference<OrderableShop> = .init()
}

// MARK: - for test

class Model {
    static func setup(stripeCustomerID: String = "cus_CC65RZ8Gf6zi7V", stripeCardID: String = "card_1BnhthKZcOra3JxsKaxABsRj", amount: Int = 1000, callback: @escaping (Order) -> Void) {
        var user: User?
        var shop: Shop?
        var product: Product?
        var sku: SKU?
        var order: Order?
        var orderShop: OrderShop?
        var orderSKU: OrderSKU?

        func fulfill() {
            if user != nil, shop != nil, product != nil, sku != nil, order != nil, orderShop != nil, orderSKU != nil {
                order?.orderSKUs.insert(orderSKU!)
                order?.update { orderError in
                    orderShop?.orderSKUs.insert(orderSKU!)
                    orderShop?.update { orderShopError in
                        if orderError == nil, orderShopError == nil { callback(order!) }
                    }
                }
            }
        }

        let newUser = User()
        newUser.stripeCustomerID = stripeCustomerID
        newUser.save { _, _ in
            user = newUser; fulfill()
        }
        let newShop = Shop()
        newShop.save { _, _ in
            shop = newShop; fulfill()
        }
        let newProduct = Product()
        newProduct.save { _, _ in
            product = newProduct; fulfill()
        }
        let newSKU = SKU()
        newSKU.save { _, _ in
            sku = newSKU; fulfill()
        }
        let newOrder = Order()
        newOrder.user.set(newUser)
        newOrder.amount = amount
        newOrder.stripeCardID = stripeCardID
        newOrder.save { _, _ in
            order = newOrder; fulfill()
        }
        let newOrderShop = OrderShop()
        newOrderShop.order.set(newOrder)
        newOrderShop.user.set(newUser)
        newOrderShop.save { _, _ in
            orderShop = newOrderShop; fulfill()
        }
        let newOrderSKU = OrderSKU()
        newOrderSKU.sku.set(newSKU)
        newOrderSKU.shop.set(newShop)
        newOrderSKU.snapshotSKU = newSKU
        newOrderSKU.snapshotProduct = newProduct
        newOrderSKU.save { _, _ in
            orderSKU = newOrderSKU; fulfill()
        }
    }
}
