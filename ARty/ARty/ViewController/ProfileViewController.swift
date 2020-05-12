//
//  ProfileViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/05/11.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ProfileViewController: UIViewController {
    
    var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 引数を出力
        print(userId ?? "nil")

        // Do any additional setup after loading the view.
    }

}
