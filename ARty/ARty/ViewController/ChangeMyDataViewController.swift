//
//  ChangeMyDataViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ChangeMyDataViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var imageSelectButton: UIButton!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    
    // ユーザー情報
    var currentUserDetailData: User?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストビューの設定
        selfIntroductionTextView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.2)
        selfIntroductionTextView.layer.borderWidth = 1
        selfIntroductionTextView.layer.cornerRadius = 5
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let closeButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.onCloseButton(_:)))
        
        // ツールバーにボタンをセット
        toolBar.setItems([flexibleItem, closeButtonItem], animated: true)

        // デリゲートを設定
        userNameTextField.delegate = self
        selfIntroductionTextView.delegate = self
        
        // テキストビューにツールバーを設定
        selfIntroductionTextView.inputAccessoryView = toolBar

        // ユーザー情報を付与
        if let user = NCMBUser.currentUser{
            userNameTextField.text = user.userName
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Actions
    // 完了ボタンを押した時
    @IBAction func decisionButtonAction(_ sender: Any) {
        if let user = NCMBUser.currentUser{
            
            user.userName = userNameTextField.text
            
            // ユーザー情報の更新
            user.signUpInBackground(callback: {result in
                switch result{
                case .success:
                    // 更新成功
                    print("userName更新に成功しました")
                    self.dismissExecute()
                    
                    // アイコンをファイルストアに保存
                    let imageData = self.imageSelectButton.currentImage?.pngData()!
                    // 日付を取得
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
                    print("date:\(dateFormatter.string(from: date))")
                    
                    // ファイル名を生成
                    let fileName = "u.\(user.objectId!).\(dateFormatter.string(from: date))"
                    print(fileName)
                    
                    // アイコン画像を保存
                    let iconFile = NCMBFile(fileName: fileName)
                    
                    
                    iconFile.saveInBackground(data: imageData!, callback: {result in
                        switch result {
                        case .success:
                            print("iconFile保存に成功")
                        case let .failure(error):
                            print("iconFile:\(error)")
                        }
                    })
                    
                    // スクリプトでデータストアを更新
                    let selfIntroduction = self.selfIntroductionTextView.text
                    
                    let script = NCMBScript(name: "pushMyDetails.js", method: .post)
                    let requestBody: [String: Any?] = ["userId": user.objectId, "selfIntroduction": selfIntroduction, "iconImageName": fileName]
                    
                    script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                        switch result {
                        case .success:
                            print("更新成功")
                        case let .failure(error):
                            print("更新失敗:\(error)")
                        }
                    })
                    
                case let .failure(error):
                    // 更新失敗
                    print("更新に失敗しました\(error)")
                    self.dismissExecute()
                }
            })
        }
    }
    
    @IBAction func imageSelectButtonAction(_ sender: Any) {
        // イメージViewを開く
        let imagePickerController = UIImagePickerController()
        
        // フォトライブラリから読み込む
        imagePickerController.sourceType = .photoLibrary
        
        // モーダルを開く
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // ツールバーの完了ボタンでキーボードを閉じる
    @objc func onCloseButton(_ sender: Any) {
        // キーボードを閉じる
        selfIntroductionTextView.endEditing(true)
        
    }
    
    func dismissExecute(){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // 前画面に戻る
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    // MARK: UITextField
    //Returnキーが押され、テキストフィールドの入力が完了する直前に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()

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
        
        // Pickerを閉じる
        dismiss(animated: true, completion: nil)
    }
}
