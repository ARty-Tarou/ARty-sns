//
//  ViewController.swift
//  ARty
//
//  Created by 今吉佑介 on 2020/04/15.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // テキストフィールドのデリゲートを設定
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    //Returnキーが押され、テキストフィールドの入力が完了する直前に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // デバッグ用 e-mail、passwordのどちらのテキストフィールドか判定
        if textField == emailTextField{
            print("email")
        }else if textField == passwordTextField{
            print("password")
        }
        return true
    }
    
    // MARK: Actions
    // Desisionボタンを押したとき
    @IBAction func desisionButtonAction(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
            // 入力されているか
            if email == "" || password == ""{
                print("入力されていない項目があるよ")
                return
            }
            
            //Userインスタンスを生成
            user = User(email: email, password: password)
            
            // 画面遷移
            performSegue(withIdentifier: "decision", sender: nil)
        }
    }
    
    @IBAction func signinButtonAction(_ sender: Any) {
        
        // 画面遷移
        performSegue(withIdentifier: "signIn", sender: nil)
    }
    
    var user: User?
    // SignUp画面に遷移するときに渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // SignUp画面のインスタンスを格納
        if let signUpViewController = segue.destination as? SignUpViewController{
            // デバッグ用出力
            print("signIn画面へ")
            
            // ユーザー情報を渡す
            signUpViewController.self.user = user
        }
    }
    
}

