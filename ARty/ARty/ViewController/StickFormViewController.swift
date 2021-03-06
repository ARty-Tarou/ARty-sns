//
//  StickFormViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class StickFormViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    // 投稿データ
    var stickImage: UIImage? = nil
    var stickData: Data? = nil
    
    // スタンプデータ
    var setStampData: [SetStampData]? = nil
    var stampImageData: [StampImageData]? = nil
    
    // ARか？
    var ar: Bool? = nil
    
    @IBOutlet weak var stickImageView: UIImageView!
    @IBOutlet weak var detailTextView: UITextView!
    
    var bool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストビューの設定
        detailTextView.text = "投稿メッセージを入力してね"
        detailTextView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.cornerRadius = 5
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // ツールバーにボタンを設定
        let buttonSize: CGFloat = 24
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let libraryButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        
        // ボタンの設定
        libraryButton.setImage(UIImage(named: "ImageFile"), for: .normal)
        cameraButton.setImage(UIImage(named: "CameraOnTwo"), for: .normal)
        libraryButton.addTarget(self, action: #selector(self.onClickLibrary(_:)), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(self.onClickCamera(_:)), for: .touchUpInside)
        let libraryButtonItem = UIBarButtonItem(customView: libraryButton)
        let cameraButtonItem = UIBarButtonItem(customView: cameraButton)
        let closeButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.onCloseButton(_:)))
        
        // ツールバーにボタンをセット
        toolBar.setItems([flexibleItem, libraryButtonItem, cameraButtonItem, flexibleItem, closeButtonItem], animated: true)
        
        // ARの投稿のとき、もらったスクショを設定
        if ar == true {
            stickImageView.image = stickImage
            
            // arのときのツールバー
            // ツールバーにボタンをセット
            toolBar.setItems([flexibleItem, closeButtonItem], animated: true)
        } else {
            // stampのときのツールバー
            // ツールバーにボタンをセット
            toolBar.setItems([libraryButtonItem, cameraButtonItem, flexibleItem, closeButtonItem], animated: true)
        }

        // デリゲートを設定
        detailTextView.delegate = self
        
        
        // テキストビューにツールバーを設定
        detailTextView.inputAccessoryView = toolBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Action
    
    // 投稿ボタンを押したとき
    @IBAction func stickButtonAction(_ sender: Any) {
        
        guard let image = stickImageView.image else{
            fatalError("画像を取得できなかったよ")
        }
        
        if ar == true {
            // stampArtの投稿
            print("arを投稿するよ")
            
            let imageData = self.stickImage!.pngData()!
            
            // StickLogicインスタンスを生成
            let stickLogic = StickLogic()
            stickLogic.saveFile(data: imageData, arData: stickData, stampImageData: stampImageData!, setStampData: setStampData!, detail: detailTextView.text)
            
        } else {
            // stampの投稿
            print("スタンプを投稿するよ")
            
            let data = image.pngData()!
            
            // StickLogicインスタンスを生成
            let stickLogic = StickLogic()
            stickLogic.saveFile(data: data, detail: detailTextView.text)
        }
        
        // タイムライン画面へ戻る
        performSegue(withIdentifier: "tab", sender: nil)
        
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
    
    // 完了ボタンでキーボードを閉じる
    @objc func onCloseButton(_ sender: Any) {
        // キーボードを閉じる
        detailTextView.endEditing(true)
        
    }
    
    // MARK: Delegate Method
    
    // テキストビューが選択されたとき
    func textViewDidBeginEditing(_ textView: UITextView) {
        if bool == false {
            detailTextView.text = ""
            detailTextView.textColor = UIColor.black
            bool = true
        }
    }
    
    // 撮影が終わったら呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 撮影した画像を渡す
        stickImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        // モーダルビューを閉じる
        dismiss(animated: true, completion: nil)
    }
}
