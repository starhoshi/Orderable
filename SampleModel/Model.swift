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
