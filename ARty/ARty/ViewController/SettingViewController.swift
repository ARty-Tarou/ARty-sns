//
//  SettingViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate{
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: Properties
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var userProductTableView: UITableView!
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Table Viewの設定
        userProductTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        userProductTableView.delegate = self
        userProductTableView.dataSource = self
        
        // カレントユーザーの情報を取得
        if let user = NCMBUser.currentUser{
            // userの名前を取得
            if let name = user.userName{
                userName.text = name
            }
            
            // ファイルストアに画像があるか検索
        }
        
        // Stampタブを選択状態にする
        stampTab.isEnabled = false
        
        // UserProductを表示する
        userProduct()
    }
    
    // MARK: Methods
    
    // UserProduct
    func userProduct(){
        if stampTab.isEnabled == false{
            // スタンプリストを表示する処理
            print("stampListを表示する")
            
            // TODO: テスト
            // スタンプリストを初期化
            stamps = []
            
            // スタンプリストを取得
            // スタンプインスタンスを生成
            let stamp1: Stamp! = Stamp(name: "ure", image: UIImage(named: "urety"))
            stamps.append(stamp1)
            
            let stamp2: Stamp! = Stamp(name: "kana", image: UIImage(named: "kanaty"))
            stamps.append(stamp2)
            
            let stamp3: Stamp! = Stamp(name: "mu", image: UIImage(named: "muty"))
            stamps.append(stamp3)
            
            var count = 1
            for stamp in stamps{
                print("stamp\(count):\(stamp.name)")
                count += 1
            }
            
            // テーブルビューを更新
            self.userProductTableView.reloadData()

            
        }else{
            // アートリストを表示する処理
            print("artListを表示する")
            stamps = []
            // テーブルViewを更新
            self.userProductTableView.reloadData()
        }
    }
    
    // MARK: TableView
    // セルの総数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // スタンプリストの総数
        return stamps.count
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    // セルに値を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        
        cell.userNameLabel.text = stamps[indexPath.row].name
        if let image = stamps[indexPath.row].image{
            cell.productImageView.image = image
        }
        
        return cell
    }
    
    
    // MARK: Actions
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        // TODO: ログアウト処理
        LogoutLogic().logout()
        // トップ画面に遷移
        performSegue(withIdentifier: "logout", sender: nil)
        
    }
    
    // changeボタンをタップしたとき
    @IBAction func changeButtonAction(_ sender: Any) {
        // 変更画面へ遷移
        performSegue(withIdentifier: "change", sender: nil)
        
    }
    
    @IBAction func stampTabButtonAction(_ sender: Any) {
        print("スタンプタブが押されたよ")
        // アートタブを未選択状態、スタンプタブを選択状態にする
        stampTab.isEnabled = false
        artsTab.isEnabled = true
        
        // テーブルViewを更新
        userProduct()
    }
    
    @IBAction func artsTabButtonAction(_ sender: Any) {
        print("アートタブが押されたよ")
        // スタンプタブを未選択状態、アートタブを選択状態にする
        stampTab.isEnabled = true
        artsTab.isEnabled = false
        
        // テーブルViewを更新
        userProduct()
    }

 }
