//
//  StickFormViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class StickFormViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var overViewTextField: UITextField!
    @IBOutlet weak var stampImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // ツールバーにボタンを設定
        let buttonSize: CGFloat = 24
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let libraryButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        // TODO: 後で変更
        libraryButton.setImage(UIImage(named: "stick"), for: .normal)
        cameraButton.setImage(UIImage(named: "stick"), for: .normal)
        libraryButton.addTarget(self, action: #selector(self.onClickLibrary(_:)), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(self.onClickCamera(_:)), for: .touchUpInside)
        let libraryButtonItem = UIBarButtonItem(customView: libraryButton)
        let cameraButtonItem = UIBarButtonItem(customView: cameraButton)
        toolBar.setItems([flexibleItem, libraryButtonItem, flexibleItem, cameraButtonItem, flexibleItem], animated: true)

        // デリゲートを設定
        overViewTextField.delegate = self
        
        // テキストフィールドにツールバーを設定
        overViewTextField.inputAccessoryView = toolBar
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
    
    // ライブラリボタンを押したとき
    @objc func onClickLibrary(_ sender: UIButton){
        print("ライブラリボタンが押されたよ")
        
        // フォトライブラリが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("ライブラリ利用可能")
            
            // UIImagePickerControllerを設定
            let imagePickerControlelr = UIImagePickerController()
            imagePickerControlelr.sourceType = .photoLibrary
            
            // デリゲートを設定
            imagePickerControlelr.delegate = self
            
            // モーダルビューを表示
            present(imagePickerControlelr, animated: true, completion: nil)
        }else{
            print("ライブラリ利用不可")
        }
    }
    
    // カメラボタンを押したとき
    @objc func onClickCamera(_ sender: UIButton){
        print("カメラボタンが押されたよ")
        
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            print("カメラ利用可能")
            
            // UIImagePickerControllerを設定
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            
            // デリゲートを設定
            imagePickerController.delegate = self
            
            // モーダルビューを表示
            present(imagePickerController, animated: true, completion: nil)
            
        }else{
            print("カメラ利用不可")
        }
    }
    
    // MARK: Delegate Method
    // テキストフィールドのリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        overViewTextField.resignFirstResponder()
        
        return true
    }
    
    // 撮影が終わったら呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 撮影した画像を渡す
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        // モーダルビューを閉じる
        dismiss(animated: true, completion: nil)
    }
}
