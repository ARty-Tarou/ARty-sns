//
//  SignInViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/19.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SignInViewController: UIViewController, UITextFieldDelegate{
    
    // MARK: Properties
    @IBOutlet weak var userNameOrMailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // テキストフィールドデリゲートを設定
        userNameOrMailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    // MARK: Delegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Actions
    @IBAction func signInButtonAction(_ sender: Any) {
        
        // 入力されているか
        if let userNameOrMailAdress = userNameOrMailAddressTextField.text, let password = passwordTextField.text{
            
            // activityIndicatorを表示、入力不可にする
            let activityIndicatorLogic = ActivityIndicatorLogic(view: view)
            activityIndicatorLogic.startActivityIndecator(view: view)
            
            // ログイン処理
            
            if SignInViewController.self.isValidEmail(userNameOrMailAdress) {
                // メールアドレスが正しく入力された場合
                print("メールアドレスっぽいです")
                let mailAddress = userNameOrMailAdress
                
                // メールアドレス＋パスワード
                NCMBUser.logInInBackground(mailAddress: mailAddress, password: password, callback: {result in
                    switch result{
                    case .success:
                        //ログインに成功した場合の処理
                        print("ログインに成功しました")
                        
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                // activityIndicatorを終了
                                activityIndicatorLogic.stopActivityIndecator(view: self.view)
                                // 画面遷移
                                self.performSegue(withIdentifier: "success", sender: nil)
                            }
                        }
                    case let .failure(error):
                        // ログインに失敗した場合の処理
                        print("ログインに失敗しました\(error)")
                        // activityIndicatorを終了
                        activityIndicatorLogic.stopActivityIndecator(view: self.view)
                    }
                })
            }else{
                // メールアドレスが正しく入力されなかった場合
                print("メールアドレスじゃなさそうかも")
                let userName = userNameOrMailAdress
                // ユーザーネーム＋パスワード
                NCMBUser.logInInBackground(userName: userName, password: password, callback: {result in
                    switch result{
                    case .success:
                        //ログインに成功した場合の処理
                        print("ログインに成功しました")
                        
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                // activityIndicatorを終了
                                activityIndicatorLogic.stopActivityIndecator(view: self.view)
                                // タブビューへ画面遷移
                                self.performSegue(withIdentifier: "success", sender: nil)
                            }
                        }
                        
                    case let .failure(error):
                        // ログインに失敗した場合の処理
                        print("ログインに失敗しました\(error)")
                        
                        DispatchQueue.global().async{
                            DispatchQueue.main.async {
                                // activityIndicatorを終了
                                activityIndicatorLogic.stopActivityIndecator(view: self.view)
                                // 画面遷移
                                self.performSegue(withIdentifier: "failed", sender: nil)
                                
                            }
                        }
                    }
                })
            }
        }else{
            print("入力されていない項目があるよ")
        }

    }
    
    // デバッグ用　ログインスルー
    @IBAction func debugButtonAction(_ sender: Any) {
        // タブビューへ画面遷移
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // 画面遷移
                self.performSegue(withIdentifier: "success", sender: nil)
            }
        }
    }
    
    // MARK: Method
    
    // 文字列がメールアドレスか判定
    class func isValidEmail(_ string: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
           let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
           let result = emailTest.evaluate(with: string)
           return result
    }
    

}
