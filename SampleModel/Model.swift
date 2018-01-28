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
    public dynamic var stockType: OrderStatus = .unknown
    public dynamic var stock: Int = 0
    public dynamic var isPublished: Bool = true
    public dynamic var isActive: Bool = true
}

@objcMembers
public class Order: Object, OrderProtocol {
    public typealias User = Demo.User

//    public typealias OrderSKU = 

}

