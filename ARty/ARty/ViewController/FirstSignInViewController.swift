//
//  FirstSignInViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/06/01.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class FirstSignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    // 誕生日のdatePicker
    let datePicker = UIDatePicker()
    
    // カレントユーザー
    let currentUser = NCMBUser.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アラートを設定
        let alertController = UIAlertController(title: "認証メール送信", message: "ユーザー認証メールを送信しました。認証後以下のボタンを押してね。", preferredStyle: .alert)
        // ダイアログに表示させるOKボタンを作成
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //アクションを追加
        alertController.addAction(defaultAction)
        //ダイアログの表示
        present(alertController, animated: true, completion: nil)
        
        // DatePickerの設定
        datePicker.datePickerMode = .date
        birthdayTextField.inputView = datePicker
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // ツールバーにボタンを設定
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.onDoneButton(_:)))
        
        // ツールバーにボタンをセット
        toolBar.setItems([flexibleItem, doneButtonItem], animated: true)
        
        // テキストビューにツールバーを設定
        birthdayTextField.inputAccessoryView = toolBar
        
        // デリゲートを設定
        userNameTextField.delegate = self
        
        // デバッグ
        print("オブジェクトID:\(String(describing: self.currentUser?.objectId))")
        print("パスワード:\(String(describing: self.currentUser?.password))")
        print("セッショントークン:\(String(describing: self.currentUser?.sessionToken))")
        
    }
    
    // MARK: Codable
    struct Confirm: Codable {
        // メール認証してますか
        let mailAddressConfirm: Bool
    }
    
    // MARK: Delegate Method
    
    // テキストフィールドのリターンが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        userNameTextField.resignFirstResponder()
        
        return true
    }

    // MARK: Action
    @IBAction func nextButtonAction(_ sender: Any) {
        
        // ユーザー名が入力されているか
        if userNameTextField.text != "" {
            
            // スクリプトでメール認証情報を取得する
            let script = NCMBScript(name: "mailAddressConfirm.js", method: .post)
            let requestBody: [String: Any?] = ["userId": currentUser?.objectId]
            let mailAddressConfirmResult = script.execute(headers: [:], queries: [:], body: requestBody)
            
            switch mailAddressConfirmResult {
            case let .success(data):
                print("\(script.name)実行に成功:\(String(data: data ?? Data(), encoding:  .utf8) ?? "")")
                
                // JSONを抽出
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(Confirm.self, from: data!)
                    
                    if json.mailAddressConfirm {
                        print("認証:\(json.mailAddressConfirm)")
                        
                        // ユーザー情報保存
                         let script = NCMBScript(name: "pushMyDetails.js", method: .post)
                         
                         // ボディを設定
                        let requestBody: [String: Any?] = ["userId": self.currentUser?.objectId, "userName": self.userNameTextField.text, "selfIntroduction": self.selfIntroductionTextView.text]
                         
                         // スクリプトを実行
                         let result = script.execute(headers: [:], queries: [:], body: requestBody)
                         
                         switch result {
                         case .success:
                             print("pushMyDetailsScript実行に成功")
                             
                             // タブビューへ遷移
                             self.performSegue(withIdentifier: "tab", sender: nil)
                            
                         case let .failure(error):
                             print("pushMyDetailsScript実行に失敗:\(error)")
                         }
                    }
                } catch {
                    print("error")
                }
            case let .failure(error):
                print("\(script.name)実行に失敗:\(error)")
            }
            
            /*
            // ユーザー情報を取得
            self.currentUser?.fetchInBackground(callback: {result in
                switch result {
                case .success:
                    print("ユーザー情報取得成功")
                    
                    // メール認証済みか
                    if self.currentUser?.isAuthenticated == true {
                        print("メール認証されてるよ")
                        
                        // ユーザー情報保存
                         let script = NCMBScript(name: "pushMyDetails.js", method: .post)
                         
                         // ボディを設定
                        let requestBody: [String: Any?] = ["userId": self.currentUser?.objectId, "userName": self.userNameTextField.text, "selfIntroduction": self.selfIntroductionTextView.text]
                         
                         // スクリプトを実行
                         let result = script.execute(headers: [:], queries: [:], body: requestBody)
                         
                         switch result {
                         case .success:
                             print("pushMyDetailsScript実行に成功")
                             
                             // タブビューへ遷移
                             self.performSegue(withIdentifier: "tab", sender: nil)
                            
                         case let .failure(error):
                             print("pushMyDetailsScript実行に失敗:\(error)")
                         }
                        
                    } else {
                        
                        print("メール認証されてないよ")
                        
                    }
                    
                case let .failure(error):
                    print("ユーザー情報取得失敗:\(error)")
                }
            })
            */
        } else {
            print("ユーザー名が入力されてないよ")
        }
        
    }
    
    @objc func onDoneButton(_ sender: UIButton) {
        // datePickerから日付を取得
        let date = datePicker.date
        // フォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        // テキストフィールドに日付を代入
        birthdayTextField.text = dateFormatter.string(from: date)
        
        // Pickerを閉じる
        self.view.endEditing(true)
    }
}
