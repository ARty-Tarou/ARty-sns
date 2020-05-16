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
    let Helptitles:NSArray = ["初めに","ARtyの使い方","カメラ機能の使い方","goodの活用方法","投稿の方法","その他"]
    
    let HelpExplanations:NSArray =
        ["Welcome to ARty!!\nこのアプリはU・22プログラミングコンテスト2020用に作成されたものです。\n本アプリでは従来のSNSアプリ同様、他のユーザー様とのコミュニケーション媒体として利用するほかAR技術を用いた機能が実装されております\nARtyの機能として実装されているものは\n\n1、ユーザー様が本アプリのAR機能を用いて撮影された写真（以下スタンプアート）の共有機能\n2、ユーザー様が作成された画像（以下スタンプ）の共有機能\n\nこの2点がメインコンテンツとなっております\n下部の画像を見ていただけるとよりご理解いただけると思いますのでぜひご覧ください。",
         "使い方",
         "カメラ機能はこうやって活用するよ",
         "グッドボタンはリンゴマークを押してね",
         "投稿はこうやってやるんだ！",
         "なんかあったらメールしてくれよ"]
    
    @IBOutlet weak var Helptitle: UILabel!
    @IBOutlet weak var HelpExplanation: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Helptitle.text = Helptitles[Int(getCell)] as? String
        HelpExplanation.text = HelpExplanations[Int(getCell)] as? String
        
        
       
    
    }
        
}


