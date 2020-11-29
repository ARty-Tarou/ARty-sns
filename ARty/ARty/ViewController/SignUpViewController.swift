//
//  SignUpViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/19.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var checkBoxButton: UIButton!
    
    
    // User情報を格納
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザー情報を取得し保存
        guard let mailAddress = user?.getMailAddress() else{
            return
        }
        guard let password = user?.getPassword() else{
            return
        }
        print("mailAddress:\(mailAddress)")
        print("password:\(password)")
        
        // チェックボックスの設定
        checkBoxButton.setImage(UIImage(named: "check"), for: .normal)
        checkBoxButton.setImage(UIImage(named: "checked"), for: .selected)
    }
    
    // MARK: Actions
    @IBAction func signUpButtonAction(_ sender: Any) {
        // 初回ログイン画面
        /*
        print("初回ログイン成功しました。")
        performSegue(withIdentifier: "signIn", sender: nil)
        */
        
        let activityIndicatorLogic = ActivityIndicatorLogic(view: view)
        activityIndicatorLogic.startActivityIndecator(view: view)
        
        if let mailAddress = user?.getMailAddress(), let password = user?.getPassword(), checkBoxButton.isSelected{
            
            // ユーザーインスタンス生成
            let user = NCMBUser()
            
            // UUID取得
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            print("uuid:\(String(describing: uuid))")
            
            // ユーザー情報格納
            user.userName = uuid
            user.mailAddress = mailAddress
            user.password = password
            var acl: NCMBACL = NCMBACL.empty
            acl.put(key: "*", readable: true, writable: true)
            user.acl = acl
            
            let signUpResult = user.signUp()
            switch signUpResult {
            case .success:
                print("仮登録に成功しました。")
                
                // TODO: ここに初回ログインを書きます pushMyDetailも動かします
                let result = NCMBUser.logIn(userName: user.userName!, password: user.password!)
                switch result {
                case .success:
                    // 初回ログイン画面
                    print("初回ログイン成功しました。")
                    performSegue(withIdentifier: "signUp", sender: nil)
                    
                case let .failure(error):
                    print("初回ログイン失敗:\(error)")
                }
                
                
                
            case let .failure(error):
                print("登録に失敗しました。：\(error)")
            }
            
            activityIndicatorLogic.stopActivityIndecator(view: view)
            
        }else{
            print("利用規約に同意されてないです")
            activityIndicatorLogic.stopActivityIndecator(view: view)
        }
        
    }
    
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
    }
    
}
