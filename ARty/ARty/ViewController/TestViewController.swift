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
        
    }
    @IBAction func startButtonAction(_ sender: Any) {
        let activityIndicatorLogic = ActivityIndicatorLogic(view: view)
        activityIndicatorLogic.startActivityIndecator(view: view)
    }
}
