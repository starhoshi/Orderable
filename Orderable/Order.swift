//
//  Order.swift
//  Orderable
//
//  Created by kensuke-hoshikawa on 2018/01/26.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import Foundation
import Pring

public typealias UserDocument = UserProtocol & Document
public typealias ShopDocument = ShopProtocol & Document
public typealias ProductDocument = ProductProtocol & Document
public typealias SKUDocument = SKUProtocol & Document
public typealias OrderDocument = OrderProtocol & Document
public typealias OrderShopDocument = OrderShopProtocol & Document
public typealias OrderSKUDocument = OrderSKUProtocol & Document

public protocol UserProtocol: class { }

public protocol ShopProtocol: class {
    var name: String? { get set }
    var isActive: Bool { get set }
    var freePostageMinimumPrice: Int { get set }
}

public protocol ProductProtocol: class {
    var name: String? { get set }
}

public enum StockType: String, Decodable {
    case unknown /// 不明: 初期値以外では基本使用しない
    case finite /// 有限: stock で在庫数を管理
    case infinite /// 無限: stock は 0 になっている
}
public protocol SKUProtocol: class {
    var price: Int { get set }
    var stockType: StockType { get set }
    var stock: Int { get set }
    var isPublished: Bool { get set }
    var isActive: Bool { get set }
}

@objc public enum OrderPaymentStatus: Int {
    case unknown = 0
    case created = 1
    case paymentRequested = 2
    case waitingForPayment = 3
    case paid = 4
}

public protocol StripeProtocol: class {
    var customerID: String? { get set }
    var cardID: String? { get set }
    var chargeID: String? { get set }
}

public protocol OrderProtocol: class {
    associatedtype OrderableUser: UserDocument
    associatedtype OrderableOrderSKU: OrderSKUDocument
    associatedtype OrderableStripe: StripeProtocol

    var user: Reference<OrderableUser> { get set }

    /// 総計
    var amount: Int { get set }

    /// 支払いが行われた日時
    var paidDate: TimeInterval { get set }

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    var expirationDate: TimeInterval { get set }
    var currency: String? { get set }
    var orderSKUs: ReferenceCollection<OrderableOrderSKU> { get set }

    /// customer payment status
    var paymentStatus: OrderPaymentStatus { get set }

    /// set Stripe if you want to use stripe charge
    var stripe: OrderableStripe? { get set }
}

//public extension OrderProtocol where Self: Object {
//    public func pay(_ block: ((Error?) -> Void)? = nil) {
//        paymentStatus = .paymentRequested
//        update { error in
//            block?(error)
//        }
//    }
//}

@objc public enum OrderShopPaymentStatus: Int {
    case unknown = 0
    case created = 1
    case paid = 2
}

public protocol OrderShopProtocol {
    associatedtype OrderableUser: UserDocument
    associatedtype OrderableOrderSKU: OrderSKUDocument

    /// 購入された商品
    var orderSKUs: ReferenceCollection<OrderableOrderSKU> { get set }

    /// 冗長化
    var user: Reference<OrderableUser> { get set }

    /// customer payment status
    var paymentStatus: OrderShopPaymentStatus { get set }
}

public protocol OrderSKUProtocol: class {
    associatedtype OrderableSKU: SKUDocument
    associatedtype OrderableShop: ShopDocument
    associatedtype SnapshotSKU: SKUProtocol
    associatedtype SnapshotProduct: ProductProtocol

    var snapshotSKU: SnapshotSKU? { get set }
    var snapshotProduct: SnapshotProduct? { get set }
    var quantity: Int { get set }
    var sku: Reference<OrderableSKU> { get set }
    var shop: Reference<OrderableShop> { get set }
}
