//
//  TestHelper.swift
//  OrderableTests
//
//  Created by kensuke-hoshikawa on 2018/01/28.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import Foundation
import FirebaseCore

class FirebaseTest {
    static let shared: FirebaseTest = FirebaseTest()
    private init () {
        FirebaseApp.configure()
    }
}
