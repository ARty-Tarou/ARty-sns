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
    let Helptitles:NSArray = ["初めに",
                              "ARtyの使い方",
                              "カメラ機能の使い方",
                              "goodの活用方法",
                              "投稿の方法",
                              "その他"]
    
    let HelpExplanations:NSArray =
        [//「初めに」の内容
            "Welcome to ARty!!\nこのアプリはU・22プログラミングコンテスト2020用に作成されたものです。\n本アプリでは従来のSNSアプリ同様、他のユーザー様とのコミュニケーション媒体として利用するほかAR技術を用いた機能が実装されております\nARtyの機能として実装されているものは\n\n1、ユーザー様が本アプリのAR機能を用いて撮影された写真（以下スタンプアート）の共有機能\n2、ユーザー様が作成された画像（以下スタンプ）の共有機能\n\nこの2点がメインコンテンツとなっております",
         //「ARtyの使い方」の内容
         "ARtyの各機能を簡単に説明します\n\n・タイムライン画面\nこの画面では自分のフォローしている人の投稿を見ることができます。またそこには自分の投稿した内容も含まれます。\nこの投稿はスタンプとスタンプアートの両方が混在しておりますのでご注意ください\n\n・トレンド\nこの画面には全投稿の中で人気な投稿を掲示します。\nフォロー・フォロワー関係なく全ユーザーが興味を持っている投稿を閲覧してよりARtyを楽しんでください\n\n・検索機能\nこの機能を使うとスタンプ、またはスタンプアートの検索が可能です。ここからまた加筆\n\n・マイページ\nこの画面からはプロフィールの変更（アイコン、紹介文）、投稿した作品の確認、ログアウト、ヘルプの確認が行えます\n\n",
         //「カメラ機能の使い方」の内容
         "カメラ機能の使い方を説明します\n\nまだできてないんです。ごめんよ",
         //「goodの活用方法」の内容
         "グッドボタンはリンゴマークを押してね\n\nこの機能があればみんなと繋がれる。\nやったね、happy",
         //「投稿の方法」の内容
         "・投稿\n画面上にある丸いアイコンをタップすると投稿画面に移ります。\n投稿する画像を選択肢、その紹介文を入力してください。\nその後右上の投稿ボタンをタップすると作成したスタンプ、またはスタンプアート が投稿されます",
         //「その他」の内容
         "なんかあったらメールしてくれよ"]
    
    
    
    let ExplanationImages:NSArray = [
        //「初めに」の画像
        "urety",
        //「ARtyの使い方」の画像
        "gamenzenbu",
        //「カメラ機能の使い方」の画像
        "kanaty",
         //「goodの活用方法」の画像
        "urety",
        //「投稿の方法」の画像
        "muty",
         //「その他」の画像
        "muty",]
    
    @IBOutlet weak var Helptitle: UILabel!
    @IBOutlet weak var HelpExplanation: UITextView!
    @IBOutlet weak var ExplanationImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Helptitle.text = Helptitles[Int(getCell)] as? String
        HelpExplanation.text = HelpExplanations[Int(getCell)] as? String
        ExplanationImage.image = UIImage(named: ExplanationImages[getCell] as! String)
       
        
       
    
    }
        
}


