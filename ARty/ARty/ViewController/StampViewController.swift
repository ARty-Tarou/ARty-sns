//
//  StampViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/07/28.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class StampViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var imageSelectButton: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        
        
    }
    
    // MARK: Method
    
    func setStampConfig() {
        print("Stamp設定を更新")
        
        
        // Stamp設定を共有
        appDelegate.stampHeight = self.stampHeight
        appDelegate.stampWidth = self.stampWidth
        appDelegate.stampImage = self.stampImage
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
        stampHeight = Int(self.heightTextField.text ?? "500")!
        stampWidth = Int(self.widthTextField.text ?? "500")!
        
        // 設定を反映
        setStampConfig()
        
    }
    
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // スタンプサイズを更新
        stampHeight = Int(self.heightTextField.text ?? "500")!
        stampWidth = Int(self.widthTextField.text ?? "500")!
        
        // 設定を反映
        setStampConfig()
        
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
        
        // 選択した画像を選択画像ビューに反映
        imageSelectButton.setImage(selectedImage, for: .normal)
        
        // 設定を反映
        stampImage = selectedImage
        setStampConfig()
        
        // スタンプ画像のサイズを出力
        print("画像の高さ:\(selectedImage.size.height)")
        print("画像の幅:\(selectedImage.size.width)")
        
        // Pickerを閉じる
        dismiss(animated: true, completion: nil)
    }

}
