//
//  TrendViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class TrendViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Action
    @IBAction func stickButtonAction(_ sender: Any) {
        // 投稿フォーム画面に遷移
        performSegue(withIdentifier: "stick", sender: nil)
    }
    

}
