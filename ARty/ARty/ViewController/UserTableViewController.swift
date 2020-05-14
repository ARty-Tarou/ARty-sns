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
    struct UserInfo: Codable{
        // ユーザーID
        let userId: String?
        // ユーザーアイコン
        let iconImageName: String?
        // UserData
        let userData: UserData?
    }
    
    struct UserData: Codable{
        // ユーザー名
        let userName: String?
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
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([UserInfo].self, from: data!)
                    
                    for followUser in json{
                        // Userインスタンスを生成
                        let user = User()
                        user.setUserId(userId: followUser.userId!)
                        user.setUserName(userName: (followUser.userData?.userName)!)
                        
                        // ファイルストアからアイコンイメージを取得
                        // ファイルを指定
                        let file = NCMBFile(fileName: followUser.iconImageName!)
                        
                        // ファイルストアからユーザーアイコンを取得
                        file.fetchInBackground(callback: {result in
                            switch result{
                            case let .success(data):
                                print("ユーザーアイコン取得に成功:\(file.fileName)")
                                
                                // データを画像に変換
                                let image = data.flatMap(UIImage.init)
                                
                                // ユーザーアイコンをセット
                                user.setUserIconImage(userIconImage: image!)
                                
                                // テーブルビューを更新
                                print("テーブルビューを更新")
                                DispatchQueue.global().async {
                                    DispatchQueue.main.async {
                                        self.userTableView.reloadData()
                                    }
                                }
                            case let .failure(error):
                                print("ユーザーアイコン取得に失敗:\(error)")
                            }
                        })
                        // ユーザーリストに追加
                        self.userList.append(user)
                        
                        // テーブルビューを更新
                        print("テーブルビューを更新")
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.userTableView.reloadData()
                            }
                        }
                    }
                }catch{
                    print("error")
                }
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
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([UserInfo].self, from: data!)
                    
                    for followerUser in json{
                        // Userインスタンスを生成
                        let user = User()
                        user.setUserId(userId: followerUser.userId!)
                        user.setUserName(userName: (followerUser.userData?.userName)!)
                        
                        // ファイルストアからアイコンイメージを取得
                        // ファイルを指定
                        let file = NCMBFile(fileName: followerUser.iconImageName!)
                        
                        // ファイルストアからユーザーアイコンを取得
                        file.fetchInBackground(callback: {result in
                            switch result{
                            case let .success(data):
                                print("ユーザーアイコン取得に成功:\(file.fileName)")
                                
                                // データを画像に変換
                                let image = data.flatMap(UIImage.init)
                                
                                // ユーザーアイコンをセット
                                user.setUserIconImage(userIconImage: image!)
                                
                                // テーブルビューを更新
                                print("テーブルビューを更新")
                                DispatchQueue.global().async {
                                    DispatchQueue.main.async {
                                        self.userTableView.reloadData()
                                    }
                                }
                            case let .failure(error):
                                print("ユーザーアイコン取得に失敗:\(error)")
                            }
                        })
                        
                        // ユーザーリストに追加
                        self.userList.append(user)
                        
                        // テーブルビューを更新
                        print("テーブルビューを更新")
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.userTableView.reloadData()
                            }
                        }
                    }
                }catch{
                    
                }
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
        
        cell.userNameLabel.text = self.userList[indexPath.row].getUserName()
        if let userIcon = self.userList[indexPath.row].getUserIconImage(){
            cell.userIconImageView.image = userIcon
        }
        
        return cell
    }
    
    // セルが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(userList[indexPath.row].getUserId() ?? nil!)
        
        // プロフィール画面へ遷移
        performSegue(withIdentifier: "profile", sender: userList[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "profile"{
            // 遷移先ViewControllerの取得
            let profileViewController = segue.destination as! ProfileViewController
            
            // プロフィール画面にユーザー情報を渡す
            let user = sender as? User
            profileViewController.user = user
        }
    }
}
