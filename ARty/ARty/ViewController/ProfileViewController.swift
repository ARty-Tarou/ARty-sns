//
//  ProfileViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/05/11.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate{
    
    // MARK: Properties
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var numberOfFollowerLabel: UILabel!
    @IBOutlet weak var numberOfFollowLabel: UILabel!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var stickCollectionView: UICollectionView!
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    // 表示するユーザー
    var user: User?
    
    // カレントユーザー
    let currentUser = NCMBUser.currentUser
    
    // 何件読んだか
    var skip = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 確認用:引数を出力
        print("情報を表示\(String(describing: user?.getUserId()))")
        
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // 画面部品にユーザーデータをセット
        var num = 0
        if let userName = user?.getUserName(){
            userNameLabel.text = userName
            num += 1
        }
        if let userIcon = user?.getUserIconImage(){
            userIconImageView.image = userIcon
            num += 10
        }
        if let numberOfFollower = user?.getNumberOfFollowed(){
            numberOfFollowerLabel.text = String(numberOfFollower)
            num += 100
        }
        if let numberOfFollow = user?.getNumberOfFollow(){
            numberOfFollowLabel.text = String(numberOfFollow)
            num += 1000
        }
        if let selfIntroduction = user?.getSelfIntroduction(){
            selfIntroductionTextView.text = selfIntroduction
            num += 10000
        }
        if let userIconImage = user?.getUserIconImage(){
            userIconImageView.image = userIconImage
            num += 100000
        }
        if user?.getFollow() != nil{
            num += 1000000
        }
        
        // followButtonのレイアウトを設定
        followButtonLayout(bool: user?.getFollow())
        
        // 未取得のユーザーの情報を補完する
        if num != 1111111{
            print("未設定のユーザー情報を取得します")
            pullYourInform()
        }else{
            print("ユーザー情報はすべて設定できています")
        }
        
        // CollectionViewの設定
        stickCollectionView.register(UINib(nibName: "StickCell", bundle: nil), forCellWithReuseIdentifier: "stickCell")
        stickCollectionView.delegate = self
        stickCollectionView.dataSource = self
        
        // Cellのレイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 340, height: 340)
        layout.scrollDirection = .horizontal
        stickCollectionView.collectionViewLayout = layout
        
        // Stampタブを選択状態にする
        stampTab.isEnabled = false
        
        // stickを取得し表示する
        userStick()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // プロフィール画面から移動する時、処理を行う
        if count % 2 == 1{
            print("フォロー情報を更新")
            let bool = user?.getFollow()!
            if let currentUser = NCMBUser.currentUser{
                if bool == true{
                    // フォローする
                    pushFollow()
                }else{
                    // フォロー解除
                    undoFollow()
                }
            }
        }
    }
    
    // MARK: Codable
    struct UserAllData: Codable{
        // UserInfo
        let result: UserInfo
        // follow情報
        let follow: Bool
    }
    
    struct UserInfo: Codable{
        // userId
        let userId: String
        // iconImageName
        let iconImageName: String
        // selfIntroduction
        let selfIntroduction: String
        // birthDay
        let birthDay: String?
        // follow
        let numberOfFollow: Int
        // follower
        let numberOfFollowed: Int
        // otherData
        let userData: UserData
    }
    
    struct UserData: Codable{
        // userName
        let userName: String
    }
    
    struct SearchResult: Codable{
        // StickData
        let stickData: [StickData]
        // skip
        let skip: Int
    }
    
    struct StickData: Codable{
        // 投稿の概要
        let detail: String
        // 投稿のgood数
        let good: Int
        // 投稿の閲覧数
        let numberOfViews: Int
        // 投稿者
        let userId: String
        // スタンプであるか
        let stamp: Bool
        // 投稿のその他の情報
        let staticData: StaticData
    }
    
    struct StaticData: Codable{
        // スタンプ名
        let stampName: String?
        // TODO: スタンプアート名 let stampArtName: String?
    }
    
    // MARK: Method
    
    func pullYourInform(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullYourInform.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": user?.getUserId(), "currentUserId": currentUser?.objectId!]
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullYourInformScript実行成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode(UserAllData.self, from: data!)
                    
                    // フォローボタンを更新
                    if self.user?.getFollow() == nil || self.user?.getFollow() != json.follow{
                        self.user?.setFollow(bool: json.follow)
                        self.followButtonLayout(bool: self.user?.getFollow())
                    }
                    
                    let userInfo = json.result
                    
                    DispatchQueue.global().async{
                        DispatchQueue.main.async {
                            // ユーザー情報を更新
                            self.selfIntroductionTextView.text = userInfo.selfIntroduction
                            self.numberOfFollowLabel.text = String(userInfo.numberOfFollow)
                            self.numberOfFollowerLabel.text = String(userInfo.numberOfFollowed)
                            self.userNameLabel.text = userInfo.userData.userName
                            if self.userIconImageView.image == nil && userInfo.iconImageName != "FirstIcon"{
                                // ファイルストアからファイルを取得
                                let file = NCMBFile(fileName: userInfo.iconImageName)
                                file.fetchInBackground(callback: {result in
                                    switch result{
                                    case let .success(data):
                                        print("ユーザーアイコン取得に成功:\(userInfo.iconImageName)")
                                        
                                        // データを画像に変換
                                        let image = data.flatMap(UIImage.init)
                                        
                                        DispatchQueue.global().async{
                                            DispatchQueue.main.async {
                                                self.userIconImageView.image = image
                                            }
                                        }
                                    case let .failure(error):
                                        print("ユーザーアイコンが取得できませんでした。:\(error)")
                                    }
                                })
                            }
                        }
                    }
                }catch{
                    print("error")
                }
            case let .failure(error):
                print("pullYourInformScript実行失敗:\(error)")
            }
        })
    }
    
    
    func userStick(){
        // スクリプトでstickリストを取得
        let script = NCMBScript(name: "pullYourStick.js", method: .post)
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": self.user?.getUserId()]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullYourStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(SearchResult.self, from: data!)
                    
                    self.skip = json.skip
                    
                    // スタンプリストを作成していく
                    for stick in json.stickData{
                        // スタンプインスタンスを生成
                        
                        if stick.stamp == true{
                            // スタンプの場合
                            // スタンプインスタンスを生成
                            let stamp: Stamp = Stamp()
                            stamp.setUserId(userId: stick.userId)
                            
                            // スタンプ・スタンプアートに関する情報をいれていく
                            stamp.setUserId(userId: stick.userId)
                            stamp.setDetail(detail: stick.detail)
                            stamp.setNumberOfGood(numberOfGood: stick.good)
                            stamp.setNumberOfViews(numberOfViews: stick.numberOfViews)
                            
                            // スタンプか、スタンプアートか
                            if stick.stamp == true{
                                // スタンプ名を代入
                                stamp.setStampName(stampName: stick.staticData.stampName!)
                                
                                // ファイルストアからスタンプを取得
                                let file = NCMBFile(fileName: stamp.getStampName()!)
                                file.fetchInBackground(callback: {result in
                                    switch result{
                                    case let .success(data):
                                        
                                        // データをUIImageに変換
                                        let image = data.flatMap(UIImage.init)
                                        
                                        // スタンプに画像を代入
                                        stamp.setStampImage(stampImage: image)
                                        
                                        // コレクションビューを更新
                                        print("コレクションビューを更新")
                                        DispatchQueue.global().async {
                                            DispatchQueue.main.async {
                                                self.stickCollectionView.reloadData()
                                            }
                                        }
                                    case let .failure(error):
                                        print("スタンプ画像取得に失敗:\(error)")
                                    }
                                })
                            }else{
                                // スタンプアート名を代入
                            }
                            
                            // スタンプリストに追加
                            self.stamps.append(stamp)
                            // コレクションビューを更新
                            print("コレクションビューを更新")
                            DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    self.stickCollectionView.reloadData()
                                }
                            }
                        }else{
                            // スタンプアートの場合（スタンプアートリストに入れていく。)
                            
                        }
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullYourStickScript実行に失敗:\(error)")
            }
        })
    }
    
    func followButtonLayout(bool: Bool?){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // 自分だった場合Buttonを隠す
                if self.user?.getUserId() == self.currentUser?.objectId{
                    self.followButton.isHidden = true
                    self.followButton.isEnabled = false
                }else{
                    if bool == true{
                        self.followButton.setTitle("フォロー解除", for: .normal)
                        self.followButton.backgroundColor = UIColor.blue
                    }else{
                        self.followButton.setTitle("フォローする", for: .normal)
                        self.followButton.backgroundColor = UIColor.green
                    }
                }
            }
        }
    }
    
    func pushFollow(){
        print("フォローするよ")
        
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pushMyFollow.js", method: .post)
        follow(script: script)
    }
    
    func undoFollow(){
        print("フォロー解除するよ")
        
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "undoFollow.js", method: .post)
        follow(script: script)
    }
    
    func follow(script: NCMBScript){
        // ボディを設定
        let requestBody: [String: Any?] = ["followerId": currentUser?.objectId, "followedUserId": user?.getUserId()]
        print("followerId:\(String(describing: currentUser?.objectId))")
        print("followedUserId:\(String(describing: user?.getUserId()))")
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case .success:
                print("\(script.name)実行に成功")
            case let .failure(error):
                print("\(script.name)実行に失敗:\(error)")
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickCell", for: indexPath) as! StickCell
        
        if stampTab.isEnabled == false{
            // スタンプリストを表示
            if let image = stamps[indexPath.row].getStampImage(){
                cell.productImageView.image = image
            }
            cell.detailTextView.text = stamps[indexPath.row].getDetail()
            cell.numberOfGood.text = String(stamps[indexPath.row].getNumberOfGood()!)
        }else{
            // スタンプアートリストを表示
        }
        return cell
        
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if stampTab.isEnabled == false{
            // スタンプの場合
            return stamps.count
        }else{
            // スタンプアートの場合
            return 0
        }
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if stampTab.isEnabled == false{
            // スタンプの場合
            print(stamps[indexPath.row].getStampName())
        }else{
            // スタンプアートの場合
            
        }
    }
    
    // MARK: Actions
    @IBAction func followListButtonAction(_ sender: Any) {
        // ユーザーテーブル画面へ遷移する
        performSegue(withIdentifier: "userTable", sender: 0)
    }
    
    @IBAction func followerListButtonAction(_ sender: Any) {
        // ユーザーテーブル画面へ遷移する
        performSegue(withIdentifier: "userTable", sender: 1)
    }
    
    // フォロー情報に変更があったか
    var count = 0
    @IBAction func followButtonAction(_ sender: Any) {
        if let bool = user?.getFollow(){
            print("フォローボタンが押されたよ:\(bool) → \(!bool)")
            count += 1
            print("フォローボタンが押された回数:\(count)")
            // フォローボタンのレイアウトを更新
            followButtonLayout(bool: !bool)
            // フォローしてます情報を更新
            user?.setFollow(bool: !bool)
            
        }else{
            print("フォロー情報がnilです")
        }
    }
    
    
    @IBAction func stampTabButtonAction(_ sender: Any) {
        print("スタンプタブが押されたよ")
        // アートタブを未選択状態、スタンプタブを選択状態にする
        stampTab.isEnabled = false
        artsTab.isEnabled = true
        
        // コレクションビューを更新
        print("コレクションビューを更新")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.stickCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func artsTabButtonAction(_ sender: Any) {
        print("アートタブが押されたよ")
        // スタンプタブを未選択状態、アートタブを選択状態にする
        stampTab.isEnabled = true
        artsTab.isEnabled = false
        
        // コレクションビューを更新
        print("コレクションビューを更新")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.stickCollectionView.reloadData()
            }
        }
    }
    
    // UINavigationController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userTable"{
            // 遷移先ViewControllerの取得
            let userTableViewController = segue.destination as! UserTableViewController
            
            // プロフィール画面にユーザー情報を渡す
            userTableViewController.userId = self.user?.getUserId()
            let category = sender as? Int
            userTableViewController.category = category
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if count % 2 == 1{
            if let bool = user?.getFollow(){
                switch bool{
                case true:
                    // フォローするよ
                    pushFollow()
                case false:
                    // フォロー解除するよ
                    undoFollow()
                }
            }
        }
    }
    
}
