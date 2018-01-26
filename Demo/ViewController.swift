//
//  ViewController.swift
//  Demo
//
//  Created by kensuke-hoshikawa on 2018/01/26.
//  Copyright © 2018年 star__hoshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let user = User()
        user.stripeCustomerID = "test"
        user.save()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

