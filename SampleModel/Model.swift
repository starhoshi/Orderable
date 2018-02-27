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
public class SampleUser: Object, UserProtocol {
}

@objcMembers
public class SampleShop: Object, ShopProtocol {
    public dynamic var name: String? = "shop_name"
    public dynamic var isActive: Bool = true
    public dynamic var freePostageMinimumPrice: Int = -1
}

@objcMembers
public class SampleProduct: Object, ProductProtocol {
    public dynamic var name: String? = "product_name"
}

@objcMembers
public class SampleSKU: Object, SKUProtocol {
    public dynamic var price: Int = 100
    public dynamic var stockType: StockType = .finite
    public dynamic var stock: Int = 100
    public dynamic var isPublished: Bool = true
    public dynamic var isActive: Bool = true
}

@objcMembers
class SampleStripe: Object, StripeProtocol {
    dynamic var customerID: String? = "cus_CC65RZ8Gf6zi7V"
    dynamic var cardID: String? = "card_1BnhthKZcOra3JxsKaxABsRj"
    dynamic var chargeID: String?
}

@objcMembers
class SampleOrder: Object, OrderProtocol {
    typealias OrderableUser = SampleUser
    typealias OrderableOrderSKU = SampleOrderSKU
    typealias OrderableStripe = SampleStripe

    dynamic var user: Reference<OrderableUser> = .init()

    /// 総計
    dynamic var amount: Int = 0

    /// 支払いが行われた日時
    dynamic var paidDate: Date?

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    dynamic var expirationDate: Date?
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
        case (\SampleOrder.paymentStatus)._kvcKeyPathString!:
            return paymentStatus.rawValue
        case (\SampleOrder.stripe)._kvcKeyPathString!:
            return stripe?.value
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\SampleOrder.paymentStatus)._kvcKeyPathString!:
            paymentStatus = (value as? Int).flatMap(OrderPaymentStatus.init(rawValue:)) ?? .unknown
            return true
        case (\SampleOrder.stripe)._kvcKeyPathString!:
            if let value = value as? [AnyHashable : Any] {
                stripe = SampleStripe(id: key, value: value)
                return true
            }
            return false
        default:
            return false
        }
    }
}

@objcMembers
class SampleOrderShop: Object, OrderShopProtocol {
    typealias OrderableUser = SampleUser
    typealias OrderableOrder = SampleOrder
    typealias OrderableOrderSKU = SampleOrderSKU

    dynamic var order: Reference<OrderableOrder> = .init()

    /// 購入された商品
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []

    dynamic var paymentStatus: OrderShopPaymentStatus = .unknown

    /// 冗長化
    dynamic var user: Reference<OrderableUser> = .init()

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case (\SampleOrderShop.paymentStatus)._kvcKeyPathString!:
            return paymentStatus.rawValue
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\SampleOrderShop.paymentStatus)._kvcKeyPathString!:
            paymentStatus = (value as? Int).flatMap(OrderShopPaymentStatus.init(rawValue:)) ?? .unknown
            return true
        default:
            return false
        }
    }
}

@objcMembers
class SampleOrderSKU: Object, OrderSKUProtocol {
    typealias OrderableSKU = SampleSKU
    typealias OrderableShop = SampleShop
    typealias SnapshotSKU = SampleSKU
    typealias SnapshotProduct = SampleProduct

    dynamic var snapshotSKU: SnapshotSKU?
    dynamic var snapshotProduct: SnapshotProduct?
    dynamic var quantity: Int = 1
    dynamic var sku: Reference<OrderableSKU> = .init()
    dynamic var shop: Reference<OrderableShop> = .init()

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case (\SampleOrderSKU.snapshotSKU)._kvcKeyPathString!:
            return snapshotSKU?.value
        case (\SampleOrderSKU.snapshotProduct)._kvcKeyPathString!:
            return snapshotProduct?.value
        default:
            return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case (\SampleOrderSKU.snapshotSKU)._kvcKeyPathString!:
            snapshotSKU = SampleSKU(id: key, value: value as! [AnyHashable: Any])
            return true
        case (\SampleOrderSKU.snapshotProduct)._kvcKeyPathString!:
            snapshotProduct = SampleProduct(id: key, value: value as! [AnyHashable: Any])
            return true
        default:
            return false
        }
    }
}

// MARK: - for test

class Model {
    static func setup(stripeCustomerID: String = "cus_CC65RZ8Gf6zi7V", stripeCardID: String = "card_1BnhthKZcOra3JxsKaxABsRj", amount: Int = 1000, callback: @escaping (SampleOrder) -> Void) {
        var user: SampleUser?
        var shop: SampleShop?
        var product: SampleProduct?
        var sku: SampleSKU?
        var order: SampleOrder?
        var orderShop: SampleOrderShop?
        var orderSKU: SampleOrderSKU?

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

        let newUser = SampleUser()
        newUser.save { _, _ in
            user = newUser; fulfill()
        }
        let newShop = SampleShop()
        newShop.save { _, _ in
            shop = newShop; fulfill()
        }
        let newProduct = SampleProduct()
        newProduct.save { _, _ in
            product = newProduct; fulfill()
        }
        let newSKU = SampleSKU()
        newSKU.save { _, _ in
            sku = newSKU; fulfill()
        }
        let newOrder = SampleOrder()
        newOrder.user.set(newUser)
        newOrder.amount = amount
        newOrder.stripe = SampleStripe()
        newOrder.paymentStatus = .created
        newOrder.save { _, _ in
            order = newOrder; fulfill()
        }
        let newOrderShop = SampleOrderShop()
        newOrderShop.order.set(newOrder)
        newOrderShop.user.set(newUser)
        newOrderShop.save { _, _ in
            orderShop = newOrderShop; fulfill()
        }
        let newOrderSKU = SampleOrderSKU()
        newOrderSKU.sku.set(newSKU)
        newOrderSKU.shop.set(newShop)
        newOrderSKU.snapshotSKU = newSKU
        newOrderSKU.snapshotProduct = newProduct
        newOrderSKU.save { _, _ in
            orderSKU = newOrderSKU; fulfill()
        }
    }
}

