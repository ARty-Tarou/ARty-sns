//
//  StickFormViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class StickFormViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var overViewTextField: UITextField!
    @IBOutlet weak var stampImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        // デリゲートを設定
        overViewTextField.delegate = self
    }
    
    // MARK: Action
    // 投稿ボタンを押したとき
    @IBAction func stickButtonAction(_ sender: Any) {
        
        // saveStickスクリプトを実行
        // スクリプトインスタンスの作成
        let script = NCMBScript(name: "saveStick.js", method: .post)
        if let user = NCMBUser.currentUser{
            // ヘッダー設定
            let headers: [String: String?] = ["userName": user.userName, "password": user.password]
            
            // スタンプイメージをデータ型に変換
            guard let image = stampImageView.image else{
                fatalError()
            }
            let data = image.pngData()
            
            let imageData = data?.base64EncodedString()
            
            print("imageData:\(String(describing: imageData))")

            // ボディ設定
            let requestBody: [String: Any?] = ["detail": overViewTextField.text, "stampData": imageData , "userId": user.objectId]
            // スクリプト実行
            script.executeInBackground(headers: headers, queries: [:], body: requestBody, callback: {result in
                switch result{
                case let .success(data):
                    print("script実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "" )")
                case let .failure(error):
                    print("script実行に失敗\(error)")
                    return;
                }
            })
        }
    }
    
    // MARK: Delegate Method
    // テキストフィールドのリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        overViewTextField.resignFirstResponder()
        
        return true
    }
}
