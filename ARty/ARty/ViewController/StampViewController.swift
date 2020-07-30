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
    
    var stampHeight = 500
    var stampWidth = 500
    var stampImage = UIImage(named: "stick")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートを設定
        heightTextField.delegate = self
        widthTextField.delegate = self
        
        // TextFieldの初期値を設定
        heightTextField.text = "300"
        widthTextField.text = "300"
        
        // ArtViewControllerを取得
        let artViewController = ArtViewController()
        
        // 設定を反映
        artViewController.stampConfigUpdate()
    }
    
    // MARK: Method
    
    func configUpdate() {
        print("Stamp設定を更新")
        // 設定内容をAR画面に渡す
        let artViewController = ArtViewController()
        artViewController.stampHeight = self.stampHeight
        artViewController.stampWidth = self.stampWidth
        artViewController.stampImage = imageSelectButton.currentImage
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
    
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // スタンプサイズを更新
        stampHeight = Int(self.heightTextField.text ?? "300")!
        stampWidth = Int(self.widthTextField.text ?? "300")!
        
        // ArtViewControllerを取得
        let artViewController = ArtViewController()
        
        // 設定を反映
        
        
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
        
        // artViewControllerに反映
        configUpdate()
        
        // スタンプ画像のサイズを出力
        print("画像の高さ:\(selectedImage.size.height)")
        print("画像の幅:\(selectedImage.size.width)")
        
        // Pickerを閉じる
        dismiss(animated: true, completion: nil)
    }

}
