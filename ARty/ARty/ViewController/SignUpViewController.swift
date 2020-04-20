//
//  SignUpViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/19.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

// MARK: Properties
    @IBOutlet weak var userIdTextField: UITextField!
    

// User情報を格納
var user: User? = nil

override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    
    //ユーザー情報を取得し保存
    guard let email = user?.getEmail() else{
        return
    }
    guard let password = user?.getPassword() else{
        return
    }
    print("email:\(email)")
    print("password:\(password)")
    
    //テキストフィールドのデリゲートを設定
    userIdTextField.delegate = self
}
    
    // MARK: Delegate Method
    
    // テキストフィールドのリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        userIdTextField.resignFirstResponder()
        
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
