//
//  ProfileViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/05/11.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    // MARK: Properties
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followerNumLabel: UILabel!
    @IBOutlet weak var FollowNumLabel: UILabel!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var stickCollectionView: UICollectionView!
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    // 表示するユーザー
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 確認用:引数を出力
        print("情報を表示\(String(describing: user?.getUserId()))")
        
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // 画面部品にユーザーデータをセット
        userNameLabel.text = user?.getUserName()
        userIconImageView.image = user?.getUserIconImage()
        
        // 未取得のユーザーの情報を補完する
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullYourInform.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": user?.getUserId()]
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullYourInformScript実行成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode([UserInfo].self, from: data!)
                    
                    for userInfo in json{
                        DispatchQueue.global().async{
                            DispatchQueue.main.async {
                                self.selfIntroductionTextView.text = userInfo.selfIntroduction
                                self.FollowNumLabel.text = String(userInfo.numberOfFollow!)
                                self.followerNumLabel.text = String(userInfo.numberOfFollowed!)
                                if self.userNameLabel.text == nil{
                                    self.userNameLabel.text = userInfo.userData?.userName
                                }
                                if self.userIconImageView.image == nil{
                                    // ファイルストアからファイルを取得
                                    let file = NCMBFile(fileName: userInfo.iconImageName!)
                                    file.fetchInBackground(callback: {result in
                                        switch result{
                                        case let .success(data):
                                            print("ユーザーアイコン取得に成功:\(userInfo.iconImageName!)")
                                            
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
                    }
                }catch{
                    print("error")
                }
            case let .failure(error):
                print("pullYourInformScript実行失敗:\(error)")
            }
        })
        
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
        
        // stickを表示する
        userStick()
        
    }
    
    // MARK: JSON
    struct UserInfo: Codable{
        // userId
        let userId: String?
        // iconImageName
        let iconImageName: String?
        // selfIntroduction
        let selfIntroduction: String?
        // birthDay
        let birthDay: String?
        // follow
        let numberOfFollow: Int?
        // follower
        let numberOfFollowed: Int?
        // otherData
        let userData: UserData?
    }
    
    struct UserData: Codable{
        // userName
        let userName: String?
    }
    
    struct StickData: Codable{
        // 投稿のgood数
        let good: Int?
        // 投稿者のuserId
        let userId: String?
        // stampかstampArtか
        let stamp: Bool?
        // スタンプデータ
        let staticData: StaticData?
    }
    
    struct StaticData: Codable{
        // スタンプ名
        let stampName: String?
        // スタンプアート名
        let stampArtName: String?
    }
    
    // MARK: Method
    func userStick(){
        // スクリプトでstickリストを取得
        let script = NCMBScript(name: "pullYourStick.js", method: .post)
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": self.user?.getUserId()]
        
        // スクリプト実行 JSON形式でこのユーザーのStickリストを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullYourStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([StickData].self, from: data!)
                    
                    // 取得したjsonのデータ数だけ回す
                    for stick in json{
                        if stick.stamp == true{
                            // スタンプの場合
                            // スタンプインスタンスを生成
                            let stamp: Stamp = Stamp()
                            stamp.setUserId(userId: stick.userId!)
                            if let stampData = stick.staticData{
                                print("stampName:\(String(describing: stampData.stampName))")
                                
                                // スタンプ名をセット
                                stamp.setStampName(stampName: stampData.stampName!)
                                
                                // ファイルストアから画像を取得
                                // ファイルの指定
                                let file = NCMBFile(fileName: stampData.stampName!)
                                
                                // ファイルの取得
                                print("画像を取ってきます:\(stampData.stampName!)")
                                file.fetchInBackground(callback: {result in
                                    switch result{
                                    case let .success(data):
                                        print("画像取得に成功:\(stampData.stampName!)")
                                        
                                        // データを画像に変換
                                        if let image = data.flatMap(UIImage.init){
                                            // スタンプに画像をセット
                                            print("画像をセット:\(stampData.stampName!)")
                                            stamp.setStampImage(stampImage: image)
                                            
                                            // コレクションビューを更新
                                            print("コレクションビューを更新")
                                            DispatchQueue.global().async {
                                                DispatchQueue.main.async {
                                                    self.stickCollectionView.reloadData()
                                                }
                                            }
                                        }
                                    case let .failure(error):
                                        print("画像取得に失敗:\(error)")
                                    }
                                })
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
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickCell", for: indexPath) as! StickCell
        
        if stampTab.isEnabled == false{
            // スタンプリストを表示
            cell.userNameLabel.text = stamps[indexPath.row].userId
            if let image = stamps[indexPath.row].stampImage{
                cell.productImageView.image = image
            }
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
            print(stamps[indexPath.row].stampName!)
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
    
    @IBAction func followButtonAction(_ sender: Any) {
        
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
    
}
