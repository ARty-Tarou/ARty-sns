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
    
    // MARK: Codable
    
    // MARK: Method
    func pullTrend(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullTrend.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": NCMBUser.currentUser?.objectId]
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullTrendScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            case let .failure(error):
                print("pullTrendScript実行に失敗:\(error)")
            }
        })
    }
    
    // MARK: Action
    @IBAction func stickButtonAction(_ sender: Any) {
        // 投稿フォーム画面に遷移
        performSegue(withIdentifier: "stick", sender: nil)
    }
    

}
