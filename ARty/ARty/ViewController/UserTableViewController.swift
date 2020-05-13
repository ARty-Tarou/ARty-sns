//
//  UserTableViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/05/13.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class UserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var userTableView: UITableView!
    
    // テーブルに表示するデータの種類を決める
    var userId: String?
    var category: Int? //0:フォロー,1:フォロワー
    
    // テーブルに表示するユーザーリスト
    var userList: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userId:\(String(describing: userId ?? nil))")
        print("category:\(String(describing: category ?? nil))")
        
        // TableViewの設定
        userTableView.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "userTableCell")
        userTableView.delegate = self
        userTableView.dataSource = self
        
        
        // テーブルビューに表示するデータを取得
        if category == 0{
            // フォローユーザーリストを表示
            pullFollow()
        }else if category == 1{
            // フォロワーユーザーリストを表示
            pullFollower()
        }
    }
    
    // MARK: JSON
    struct UserData: Codable{
        // フォローユーザーId
        let followId: String?
        // フォロワーユーザーId
        let followerId: String?
    }
    
    // MARK: Methods
    func pullFollow(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullFollow.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": self.userId!]
        // スクリプト実行
        // JSON形式でフォローユーザーリストを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullFollowScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
            case let .failure(error):
                print("pullFollowScript実行に失敗:\(error)")
            }
        })
    }
    
    func pullFollower(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullFollower.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": self.userId!]
        // スクリプト実行
        // JSON形式でフォロワーユーザーリストを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullFollowerScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            case let .failure(error):
                print("pullFollowerScript実行に失敗:\(error)")
            }
        })
    }
    
    // MARK: UITableViewDataSource

    // セル数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ユーザーデータの総数
        return userList.count
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableCell") as! UserTableCell
        
        cell.userNameLabel.text = "aaa"
        
        return cell
    }
}
