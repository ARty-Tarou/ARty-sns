//
//  TestViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/28.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // ログアウト処理
        _ = LogoutLogic().logout()
    }
}
