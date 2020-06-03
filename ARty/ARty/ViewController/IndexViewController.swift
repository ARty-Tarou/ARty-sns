//
//  ViewController.swift
//  ARty
//
//  Created by 今吉佑介 on 2020/04/15.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class IndexViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ログインしているかチェック
        //loginCheck()
 
        // テキストフィールドのデリゲートを設定
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    //テキストフィールドの入力が完了する直前に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Method
    // ログインしているかチェックする
    func loginCheck(){
        /*
        if let user = NCMBUser.currentUser {
            user.fetchInBackground(callback: {result in
                switch result {
                case .success:
                    print("ユーザー情報取得成功")
                    
                    // タブビューへ遷移
                    self.performSegue(withIdentifier: "tab", sender: nil)
                    
                case let .failure(error):
                    print("ユーザー情報取得失敗:\(error)")
                }
            })
        }*/
    }
    
    // MARK: Actions
    // Desisionボタンを押したとき
    @IBAction func desisionButtonAction(_ sender: Any) {
        
        if let mailAddress = mailAddressTextField.text, let password = passwordTextField.text{
            
            // 入力されているか
            if mailAddress == "" || password == ""{
                print("入力されていない項目があるよ")
                return
            }
            
            //Userインスタンスを生成
            user = User(mailAddress: mailAddress, password: password)
            
            // 画面遷移
            performSegue(withIdentifier: "decision", sender: nil)
        }
    }
    
    @IBAction func signinButtonAction(_ sender: Any) {
        
        // 画面遷移
        performSegue(withIdentifier: "signIn", sender: nil)
    }
    
    
    // MARK: Segue
    var user: User?
    // SignUp画面に遷移するときに渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // SignUp画面のインスタンスを格納
        if let signUpViewController = segue.destination as? SignUpViewController{
            // デバッグ用出力
            print("signUp画面へ")
            
            // ユーザー情報を渡す
            signUpViewController.user = user
        }
    }
    
}

