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
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var fontSize: Float = 0.003
    var lineColor = UIColor.lightGray

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを設定
        fontSizeTextField.delegate = self
        
        // fontSizeを初期化
        setFontSize()
        
        
                
    }
    
    // MARK: Method
    func setFontSize() {
        if var value = Int(fontSizeTextField.text!) {
            
            // サイズが1~10以外の数値の場合初期値を入れる
            if value < 1 || 10 < value {
                self.fontSizeTextField.text = "3"
                value = 3
            }
            
            // fontSizeを更新
            fontSize = Float(value)/1000
        }
        
    }
    
    // MARK: Action
    @IBAction func redSlider(_ sender: UISlider) {
        appDelegate.red = CGFloat(sender.value)
    }
    @IBAction func greenSlider(_ sender: UISlider) {
        appDelegate.green = CGFloat(sender.value)
    }
    @IBAction func blueSlider(_ sender: UISlider) {
        appDelegate.blue = CGFloat(sender.value)
    }
    
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // フォントサイズを更新
        setFontSize()
        
        appDelegate.fontSize = self.fontSize
        
        return true
    }

}
