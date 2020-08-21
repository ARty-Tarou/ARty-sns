//
//  GraffitiViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/07/28.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class GraffitiViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var fontSizeTextField: UITextField!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var fontSize: Float = 0.003
    var lineColor = UIColor.lightGray
    
    var red: CGFloat = 0.5
    var green: CGFloat = 0.5
    var blue: CGFloat = 0.5

    @IBOutlet weak var preview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ツールバーを設定
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // ツールバーにボタンを設定
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let closeButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.onCloseButton(_:)))
        
        
        // ツールバーにボタンをセット
        toolBar.setItems([flexibleItem, closeButtonItem], animated: true)
        
        // テキストフィールドにツールバーを設定
        fontSizeTextField.inputAccessoryView = toolBar
        
        
        // デリゲートを設定
        fontSizeTextField.delegate = self
        
        // fontを初期化
        setFontSize()
        setLineColor()
        
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
            self.fontSize = Float(value)/1000
            
            appDelegate.fontSize = self.fontSize
            
            let width =  CGFloat(value) * 7
            let height = CGFloat(value) * 7
            
            preview.frame = CGRect(x: preview.frame.minX, y: preview.frame.minY, width: width, height: height)
            
        }
    }
    
    func setLineColor() {
        appDelegate.lineColor = UIColor(red: self.red, green: self.green, blue: self.blue, alpha: 1)
        
        preview.backgroundColor = UIColor(red: self.red, green: self.green, blue: self.blue, alpha: 1)
    }
    
    // MARK: Action
    @IBAction func redSlider(_ sender: UISlider) {
        self.red = CGFloat(sender.value)
        
        setLineColor()
    }
    @IBAction func greenSlider(_ sender: UISlider) {
        self.green = CGFloat(sender.value)
        
        setLineColor()
    }
    @IBAction func blueSlider(_ sender: UISlider) {
        self.blue = CGFloat(sender.value)
        
        setLineColor()
    }
    
    // 完了ボタンでキーボードを閉じる
    @objc func onCloseButton(_ sender: Any) {
        // キーボードを閉じる
        fontSizeTextField.resignFirstResponder()
        
        // 設定を反映
        setFontSize()
    }
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // フォントサイズを更新
        setFontSize()
        
        return true
    }

}
