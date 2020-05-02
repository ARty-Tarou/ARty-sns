//
//  SignUpViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/19.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    
    // User情報を格納
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //ユーザー情報を取得し保存
        guard let mailAddress = user?.getMailAddress() else{
            return
        }
        guard let password = user?.getPassword() else{
            return
        }
        print("mailAddress:\(mailAddress)")
        print("password:\(password)")
        
        //テキストフィールドのデリゲートを設定
        userNameTextField.delegate = self
        
        // チェックボックスのし設定
        checkBoxButton.setImage(UIImage(named: "check_off"), for: .normal)
        checkBoxButton.setImage(UIImage(named: "check_on"), for: .selected)
    }
    
    // MARK: Delegate Method
    
    // テキストフィールドのリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        userNameTextField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Actions
    @IBAction func signUpButtonAction(_ sender: Any) {
        
        if let userName = userNameTextField.text, let mailAddress = user?.getMailAddress(), let password = user?.getPassword(), checkBoxButton.isSelected{
            // ユーザーインスタンス生成
            let user = NCMBUser()
            
            // ユーザー情報格納
            user.userName = userName
            user.mailAddress = mailAddress
            user.password = password
            
            
            // ニフクラに新規会員登録
            user.signUpInBackground(callback: {result in
                switch result{
                case .success:
                    // 新規登録に成功した場合の処理
                    print("登録に成功")
                    
                case let .failure(error):
                    // 新規登録に失敗した場合の処理
                    print("登録失敗:\(error)")
                }
            })
        }else{
            print("利用規約に同意されてないです")
        }
    }
    
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
    }
    
}
