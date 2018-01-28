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
    public dynamic var stripeCustomerID: String?
}

@objcMembers
public class Shop: Object, ShopProtocol {
    public dynamic var name: String?
    public dynamic var isActive: Bool = true
    public dynamic var freePostageMinimunPrice: Int = -1
}

@objcMembers
public class Product: Object, ProductProtocol {
    public dynamic var name: String?
}

@objcMembers
public class SKU: Object, SKUProtocol {
    public dynamic var price: Int = 0
    public dynamic var stockType: StockType = .unknown
    public dynamic var stock: Int = 0
    public dynamic var isPublished: Bool = true
    public dynamic var isActive: Bool = true
}

@objcMembers
class Order: Object, OrderProtocol {
    typealias OrderableUser = User
    typealias OrderableOrderSKU = OrderSKU

    dynamic var user: Reference<OrderableUser> = .init()

    /// ストライプに登録したカード情報。このカードIDで決済を行う
    dynamic var stripeCardID: String?

    /// 総計
    dynamic var amount: Int = 0

    /// 支払いが行われた日時
    dynamic var paidDate: TimeInterval = 0

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    dynamic var expirationDate: TimeInterval = 0
    dynamic var stripeChargeID: String?
    dynamic var currency: String?
    dynamic var status: Int = OrderStatus.unknown.rawValue
    dynamic var orderSKUs: ReferenceCollection<OrderableOrderSKU> = []
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
    dynamic var status: Int = OrderShopStatus.unknown.rawValue

    /// 冗長化
    dynamic var user: Reference<OrderableUser> = .init()

}

@objcMembers
class OrderSKU: Object, OrderSKUProtocol {
    typealias OrderableSKU = SKU
    typealias OrderableShop = Shop

    dynamic var snapshotSKU: SKUProtocol?
    dynamic var snapshotProduct: ProductProtocol?
    dynamic var quantity: Int = 0
    dynamic var sku: Reference<OrderableSKU> = .init()
    dynamic var shop: Reference<OrderableShop> = .init()
}
