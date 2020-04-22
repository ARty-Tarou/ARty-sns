//
//  ChangeSettingViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ChangeSettingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var selfIntroductionTextField: UITextField!
    
    var childCallBack: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        userNameTextField.delegate = self
        selfIntroductionTextField.delegate = self
        
        if let user = NCMBUser.currentUser{
            userNameTextField.text = user.userName
            selfIntroductionTextField.text = ""
        }

    }
    
    // MARK: Actions
    @IBAction func decisionButtonAction(_ sender: Any) {
        if let user = NCMBUser.currentUser{
            
            user.userName = userNameTextField.text
            
            // ユーザー情報の更新
            user.signUpInBackground(callback: {result in
                switch result{
                case .success:
                    // 更新成功
                    print("更新に成功しました")
                    self.dismissExecute()
                    
                case let .failure(error):
                    // 更新失敗
                    print("更新に失敗しました\(error)")
                    self.dismissExecute()
                }
            })
        }
    }
    
    func dismissExecute(){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // 前画面に戻る
                self.dismiss(animated: true){
                    self.childCallBack
                }
            }
        }
    }
 
    
    // MARK: Delegate Method
    //Returnキーが押され、テキストフィールドの入力が完了する直前に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()

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
