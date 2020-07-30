//
//  GraffitiViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/07/28.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class GraffitiViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var fontSizeTextField: UITextField!
    
    var fontSize: Float = 0.0
    var lineColor = UIColor.lightGray

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを設定
        fontSizeTextField.delegate = self
        
        // fontSizeを初期化
        setFontSize()
        
        // ArtViewControllerを取得
        //let artViewController = ArtViewController()
        
        // 設定を反映
        
        print("fontSize4 : \(self.fontSize)")
                
    }
    
    // Method
    func setFontSize() {
        if var value = Int(fontSizeTextField.text!) {
            
            // サイズが1~10以外の数値の場合初期値を入れる
            if value < 1 || 10 < value {
                self.fontSizeTextField.text = "5"
                value = 5
            }
            
            // fontSizeを更新
            fontSize = Float(value)/1000
            //print("fontSize in Graffiti:\(self.fontSize)")
        }
        
        print("graffiti : \(fontSize)")
        
        var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.fontSize = fontSize
        
        print("delegate graffiti : \(appDelegate.fontSize)")
        
        // ArtViewControllerを取得
        let artViewController = ArtViewController()
        
        // 設定を反映
        artViewController.graffitiConfigUpdate()
    }
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // フォントサイズを更新
        setFontSize()
        
        //print("fontSize in Graffiti2:\(self.fontSize)")
        
        return true
    }

}
