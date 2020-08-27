//
//  StampViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/07/28.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class StampViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var imageSelectButton: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let currentUser = NCMBUser.currentUser
    
    var stampHeight = 500
    var stampWidth = 500
    var stampImage = UIImage(named: "stick")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // ツールバーにボタンを設定
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let closeButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.onCloseButton(_:)))
        
        // ツールバーにボタンをセット
        toolBar.setItems([flexibleItem, closeButtonItem], animated: true)
        
        // テキストフィールドにツールバーを設定
        heightTextField.inputAccessoryView = toolBar
        widthTextField.inputAccessoryView = toolBar

        // デリゲートを設定
        heightTextField.delegate = self
        widthTextField.delegate = self
        
        // TextFieldの初期値を設定
        heightTextField.text = "500"
        widthTextField.text = "500"
        
        // 設定を共有
        setStampSizeConfig()
        setStampImageConfig(selectedImage: self.stampImage!)
    }
    
    // MARK: Method
    
    func setStampSizeConfig() {
        print("StampSize設定を更新")
        
        
        // StampSize設定を共有
        appDelegate.stampHeight = self.stampHeight
        appDelegate.stampWidth = self.stampWidth
    }
    
    func setStampImageConfig(selectedImage: UIImage) {
        print("StampImage設定を更新")
        
        // 画像を更新
        self.stampImage = selectedImage
        
        // 選択画像をビューに表示
        self.imageSelectButton.setImage(self.stampImage, for: .normal)
        
        // StampImage設定を共有
        // 変更前のスタンプが一度でも使われているか
        if appDelegate.stampImageUsed == true {
            // 使われていた場合、stampNumberを加算
            appDelegate.stampImageIndex += 1
        }
        
        // stampNumberを取得
        let stampNumber = appDelegate.stampImageIndex
        
        // stampImageNameを生成
        // 日付を取得
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
        
        guard let objectId = currentUser?.objectId else {
            fatalError("カレントユーザー取得失敗")
        }
        
        let stampImageName = "d.\(objectId).\(dateFormatter.string(from: date))"
        
        // StampImageDataインスタンスを生成
        let stampImageData = StampImageData(stampImage: self.stampImage!, stampImageName: stampImageName, stampNumber: stampNumber)
        
        // stampImageを共有
        if appDelegate.stampImageUsed == true || appDelegate.stampImageIndex == 0 {
            print("0番目とか")
            appDelegate.stampImageData.append(stampImageData)
        } else {
            appDelegate.stampImageData[appDelegate.stampImageIndex] = stampImageData
        }
        
        print("stampImageData(ImageConfig)Name:\(self.appDelegate.stampImageData.first?.getStampImageName())")
                print("stampImageData(ImageConfig)Number:\(self.appDelegate.stampImageData.first?.getStampNumber())")
    }
    
    
    // MARK: Action
    
    // ImageButtonを押したとき
    @IBAction func ImageSelectButtonAction(_ sender: Any) {
        // イメージViewを開く
        let imagePickerController = UIImagePickerController()
        
        // フォトライブラリから読み込む
        imagePickerController.sourceType = .photoLibrary
        
        // モーダルを開く
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // 完了ボタンでキーボードを閉じる
    @objc func onCloseButton(_ sender: Any) {
        // キーボードを閉じる
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        
        // スタンプサイズを更新
        if self.heightTextField.text == "" {
            self.heightTextField.text = "500"
        }
        if self.widthTextField.text == "" {
            self.widthTextField.text = "500"
        }
        
        stampHeight = Int(self.heightTextField.text ?? "500")!
        stampWidth = Int(self.widthTextField.text ?? "500")!
        
        // 設定を反映
        setStampSizeConfig()
        
    }
    
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // スタンプサイズを更新
        stampHeight = Int(self.heightTextField.text ?? "500")!
        stampWidth = Int(self.widthTextField.text ?? "500")!
        
        // 設定を反映
        setStampSizeConfig()
        
        return true
    }
    
    // MARK: UIImagePickerController
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // 画像を選択した後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError()
        }
        
        // スタンプ画像のサイズを出力
        print("画像の高さ:\(selectedImage.size.height)")
        print("画像の幅:\(selectedImage.size.width)")
        
        // 設定を反映
        setStampImageConfig(selectedImage: selectedImage)
        
        // Pickerを閉じる
        dismiss(animated: true, completion: nil)
    }

}
