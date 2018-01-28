//
//  Order.swift
//  Orderable
//
//  Created by kensuke-hoshikawa on 2018/01/26.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import Foundation
import Firebase
import Pring

public typealias UserDocument = UserProtocol & Document
public typealias ShopDocument = ShopProtocol & Document
public typealias ProductDocument = ProductProtocol & Document
public typealias SKUDocument = SKUProtocol & Document
public typealias OrderDocument = OrderProtocol & Document
public typealias OrderShopDocument = OrderShopProtocol & Document
public typealias OrderSKUDocument = OrderSKUProtocol & Document

public protocol UserProtocol: class {
    var stripeCustomerID: String? { get set }
}

public protocol ShopProtocol: class {
    var name: String? { get set }
    var isActive: Bool { get set }
    var freePostageMinimunPrice: Int { get set }
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
    var stockType: OrderStatus { get set }
    var stock: Int { get set }
    var isPublished: Bool { get set }
    var isActive: Bool { get set }
}


public enum OrderStatus: Int {
    case unknown = 0
    case created = 1 // Order 作成完了したがユーザが同意ボタンをまだ押していない
    case paymentRequested = 2 // ユーザが購入ボタンに同意した
    case waitingForPayment = 3 // ユーザが銀行振込などで待ちの状態
    case paid = 4 // 支払い完了
}

public protocol OrderProtocol: class {
    associatedtype OrderableUser: UserDocument
    associatedtype OrderableOrderSKU: OrderSKUDocument

    var user: Reference<OrderableUser> { get set }

    /// ストライプに登録したカード情報。このカードIDで決済を行う
    var stripeCardID: String? { get set }

    /// 総計
    var amount: Int { get set }

    /// 支払いが行われた日時
    var paidDate: TimeInterval { get set }

    /// 有効期限 この期限を過ぎたらこのオーダーは無効になる
    var expirationDate: TimeInterval { get set }
    var status: OrderStatus { get set }
    var stripeChargeID: String? { get set }
    var currency: String? { get set }
    var orderSKUs: ReferenceCollection<OrderableOrderSKU> { get set }
}

//public extension OrderProtocol where Self: Object {
//    public func payOrder(_ block: ((Error?) -> Void)? = nil) {
//        amount = 100
//        update { error in
//            block?(error)
//        }
//    }
//}

public enum OrderShopStatus: Int {
    case unknown = 0
    case created = 1 // オーダー作成が完了したが支払いが行われていない
    case paid = 2 // 支払いが行われ発送待ち
    case delivered = 3 // 発送済
    case received = 4 // (customerが)受け取り済
}

public protocol OrderShopProtocol {
    associatedtype OrderableUser: UserDocument
//    associatedtype OrderableOrder: OrderDocument
    associatedtype OrderableOrderSKU: OrderSKUDocument

    /// parent
//    var order: Reference<OrderableOrder> { get set }

    /// 購入された商品
    var orderSKUs: ReferenceCollection<OrderableOrderSKU> { get set }

    /// 配送ステータス
    var status: OrderShopStatus { get set }

    /// 冗長化
    var user: Reference<OrderableUser> { get set }

//    override func encode(_ key: String, value: Any?) -> Any? {
//        switch key {
//        case (\Firebase.OrderShop.snapshotShop)._kvcKeyPathString!:
//            return snapshotShop?.value
//        case (\Firebase.OrderShop.status)._kvcKeyPathString!:
//            return status.rawValue
//        default:
//            return nil
//        }
//    }
//
//    override func decode(_ key: String, value: Any?) -> Bool {
//        switch key {
//        case (\Firebase.OrderShop.snapshotShop)._kvcKeyPathString!:
//            snapshotShop = Firebase.Shop(id: key, value: value as! [AnyHashable: Any])
//            return true
//        case (\Firebase.OrderShop.status)._kvcKeyPathString!:
//            status = (value as? Int).flatMap(Status.init(rawValue:)) ?? .unknown
//            return true
//        default:
//            return false
//        }
//    }
}

public protocol OrderSKUProtocol: class {
    associatedtype OrderableSKU: SKUDocument
    associatedtype OrderableShop: ShopDocument

    var snapshotSKU: SKUProtocol? { get set }
    var snapshotProduct: ProductProtocol? { get set }
    var quantity: Int { get set }
    var sku: Reference<OrderableSKU> { get set }
    var shop: Reference<OrderableShop> { get set }
}