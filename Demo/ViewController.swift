//
//  ViewController.swift
//  Demo
//
//  Created by kensuke-hoshikawa on 2018/01/26.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import UIKit
import Pring

class ViewController: UIViewController {
    @IBOutlet weak var stripeCustomerIDField: UITextField!
    @IBOutlet weak var stripeCardIDField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    var disposer: Disposer<Order>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func didTapOrderButton(_ sender: Any) {
        Model.setup(stripeCustomerID: stripeCustomerIDField.text!, stripeCardID: stripeCardIDField.text!, amount: 1000) { [weak self] order in
            order.paymentStatus = OrderPaymentStatus.paymentRequested
            order.update()
            self?.disposer = Order.listen(order.id) { o, e in
                if o?.stripeChargeID != nil {
                    var results: [String] = []
                    results.append("OrderID: \(order.id)")
                    results.append("UserID: \(order.user.id ?? "")")
                    results.append("StripeChargeID: \(o?.stripeChargeID ?? "")")
                    self?.resultLabel.text = results.joined(separator: "\n")
                }
            }
        }
    }
}
