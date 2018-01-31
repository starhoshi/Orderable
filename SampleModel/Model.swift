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
}

@objcMembers
public class Shop: Object, ShopProtocol {
    public dynamic var name: String? = "shop_name"
    public dynamic var isActive: Bool = true
    public dynamic var freePostageMinimumPrice: Int = -1
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
class Stripe: Object, StripeProtocol {
    dynamic var customerID: String? = "cus_CC65RZ8Gf6zi7V"
    dynamic var cardID: String? = "card_1BnhthKZcOra3JxsKaxABsRj"
    dynamic var chargeID: String?
}

@objcMembers
class Order: Object, OrderProtocol {
    typealias OrderableUser = User
    typealias OrderableOrderSKU = OrderSKU
    typealias OrderableStripe = Stripe

    dynamic var user: Reference<OrderableUser> = .init()

    /// 総計
    dynamic var amount: Int = 0

    /// 支払いが行われた日時
    dynamic var paidDate: TimeInterval = 0

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    dynamic var expirationDate: TimeInterval = 0
    dynamic var currency: String? = "jpy"
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []

    /// for Komerco
    dynamic var skuPriceSum: Int = 0
    dynamic var postage: Int = 0
    dynamic var prefectureID: Int = 0
    dynamic var regionID: Int = 0

    dynamic var paymentStatus: OrderPaymentStatus = .unknown
    dynamic var stripe: OrderableStripe?

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case (\Order.paymentStatus)._kvcKeyPathString!:
            return paymentStatus.rawValue
        case (\Order.stripe)._kvcKeyPathString!:
            return stripe?.value
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\Order.paymentStatus)._kvcKeyPathString!:
            paymentStatus = (value as? Int).flatMap(OrderPaymentStatus.init(rawValue:)) ?? .unknown
            return true
        case (\Order.stripe)._kvcKeyPathString!:
            if let value = value as? [AnyHashable : Any] {
                stripe = Stripe(id: key, value: value)
                return true
            }
            return false
        default:
            return false
        }
    }
}

@objcMembers
class OrderShop: Object, OrderShopProtocol {
    typealias OrderableUser = User
    typealias OrderableOrder = Order
    typealias OrderableOrderSKU = OrderSKU

    dynamic var order: Reference<OrderableOrder> = .init()

    /// 購入された商品
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []

    dynamic var paymentStatus: OrderShopPaymentStatus = .unknown

    /// 冗長化
    dynamic var user: Reference<OrderableUser> = .init()

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case (\OrderShop.paymentStatus)._kvcKeyPathString!:
            return paymentStatus.rawValue
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\OrderShop.paymentStatus)._kvcKeyPathString!:
            paymentStatus = (value as? Int).flatMap(OrderShopPaymentStatus.init(rawValue:)) ?? .unknown
            return true
        default:
            return false
        }
    }
}

@objcMembers
class OrderSKU: Object, OrderSKUProtocol {
    typealias OrderableSKU = SKU
    typealias OrderableShop = Shop
    typealias SnapshotSKU = SKU
    typealias SnapshotProduct = Product

    dynamic var snapshotSKU: SnapshotSKU?
    dynamic var snapshotProduct: SnapshotProduct?
    dynamic var quantity: Int = 1
    dynamic var sku: Reference<OrderableSKU> = .init()
    dynamic var shop: Reference<OrderableShop> = .init()

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case (\OrderSKU.snapshotSKU)._kvcKeyPathString!:
            return snapshotSKU?.value
        case (\OrderSKU.snapshotProduct)._kvcKeyPathString!:
            return snapshotProduct?.value
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\OrderSKU.snapshotSKU)._kvcKeyPathString!:
            snapshotSKU = SKU(id: key, value: value as! [AnyHashable: Any])
            return true
        case (\OrderSKU.snapshotProduct)._kvcKeyPathString!:
            snapshotProduct = Product(id: key, value: value as! [AnyHashable: Any])
            return true
        default:
            return false
        }
    }
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
        newOrder.stripe = Stripe()
        newOrder.stripe?.cardID = ""
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

