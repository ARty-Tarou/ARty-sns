//
//  SubHelpViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/05/14.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import Foundation
import UIKit

class SubHelpViewController: UIViewController{
    //Helppageで選択されたセルの番号を取得
    var getCell: Int!
    //予めのタイトル設置
    let Helptitles:[String] = ["ARtyへようこそ","ARtyの使い方","カメラ機能の使い方","goodの活用方法","投稿の方法","その他"]
    
    let HelpExplanation:[String] =
        ["ARtyへようこそまいりました",
         "使い方を説明するよ",
         "カメラ機能はこうやって活用するよ",
         "グッドボタンはリンゴマークを押してね",
         "なんかあったらメールしてくれよ"]
    
    @IBOutlet weak var Helptitle: UILabel!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
       
        if getCell == 0{
               Helptitle.text = Helptitles[0]
        }else if getCell == 1{
                Helptitle.text = Helptitles[1]
        }else if getCell == 2{
                Helptitle.text = Helptitles[2]
        }else if getCell == 3{
                Helptitle.text = Helptitles[3]
        }else if getCell == 4{
                Helptitle.text = Helptitles[4]
        }else{
            print("何かしらがnilじゃ")
        }
    }


    
        
}


