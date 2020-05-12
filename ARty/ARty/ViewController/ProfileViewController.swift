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
    
    // MARK: Properties
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var stickCollectionView: UICollectionView!
    
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 引数を出力
        print("情報を表示\(userId!)")
        
        // 表示するユーザーの情報を取得する
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullYourInform.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": userId!]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullYourInformScript実行成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                
            case let .failure(error):
                print("pullYourInformScript実行失敗:\(error)")
            }
        })
        
        // TODO: 画面部品にユーザーデータをセット
        
        // CollectionViewの設定
        stickCollectionView.register(UINib(nibName: "StickCell", bundle: nil), forCellWithReuseIdentifier: "stickCell")
        
        // Cellのレイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 350, height: 300)
        layout.scrollDirection = .horizontal
        stickCollectionView.collectionViewLayout = layout
        
        // Stampタブを選択状態にする
        stampTab.isEnabled = false
        
    }
    
    // MARK: JSON
    struct User: Codable{
        // userId
        let userId: String?
        // userName
        let userName: String?
    }
    
    // MARK: Actions
    @IBAction func stampTabButtonAction(_ sender: Any) {
        print("スタンプタブが押されたよ")
        // アートタブを未選択状態、スタンプタブを選択状態にする
        stampTab.isEnabled = false
        artsTab.isEnabled = true
        
        // コレクションビューを更新

    }
    
    @IBAction func artsTabButtonAction(_ sender: Any) {
        print("アートタブが押されたよ")
        // スタンプタブを未選択状態、アートタブを選択状態にする
        stampTab.isEnabled = true
        artsTab.isEnabled = false
        
        // コレクションビューを更新
        
    }
    
}
