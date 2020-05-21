//
//  MyPageViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class MyPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    // MARK: Properties
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    @IBOutlet weak var numberOfFollowLabel: UILabel!
    @IBOutlet weak var numberOfFollowerLabel: UILabel!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var myStickCollectionView: UICollectionView!
    
    // カレントユーザー
    let user = NCMBUser.currentUser
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    // 何件読んだか
    var skip = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // userNameLabelにユーザー名を設定
        userNameLabel.text = user?.userName
        
        //　未取得のユーザー情報を補完
        pullMyInform()
        
        // CollectionViewの設定
        myStickCollectionView.register(UINib(nibName: "StickCell", bundle: nil), forCellWithReuseIdentifier: "stickCell")
        myStickCollectionView.delegate = self
        myStickCollectionView.dataSource = self
        
        // Cellのレイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 340, height: 340)
        layout.scrollDirection = .horizontal
        myStickCollectionView.collectionViewLayout = layout
        
        // Stampタブを選択状態にする
        stampTab.isEnabled = false
        
        // UserStickを表示する
        userStick()
    }
    
    // MARK: JSON
    struct UserInfo: Codable{
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
    }
    
    struct SearchResult: Codable{
        // StickData
        let result: [StickData]
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
        //let staticData: StaticData
    }
    
    struct StaticData: Codable{
        // スタンプ名
        let stampName: String?
        // スタンプアート名
        // let stampArtName: String?
    }
    
    // MARK: Methods
    
    func pullMyInform(){
        // スクリプトインスタンス生成
        let script = NCMBScript(name: "pullMyInform.js", method: .post)
        
        // ボディ設定
        let requestBody:[String: Any?] = ["userId": self.user?.objectId]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyInformScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode([UserInfo].self, from: data!)
                    
                    if let userInfo = json.first{
                        DispatchQueue.global().async{
                            DispatchQueue.main.async {
                                self.selfIntroductionTextView.text = userInfo.selfIntroduction
                                self.numberOfFollowLabel.text = String(userInfo.numberOfFollow)
                                self.numberOfFollowerLabel.text = String(userInfo.numberOfFollowed)
                                
                                if self.userIconImageView.image == nil{
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
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullMyInformScript実行に失敗:\(error)")
            }
        })
    }
    
    func userStick(){
        // スクリプトでstickリストを取得
        let script = NCMBScript(name: "pullMyStick.js", method: .post)
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": self.user?.objectId]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(SearchResult.self, from: data!)
                    
                    self.skip = json.skip
                    
                    // スタンプリストを作成していく
                    /*
                    for stick in json.result{
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
                                                self.myStickCollectionView.reloadData()
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
                                    self.myStickCollectionView.reloadData()
                                }
                            }
                        }else{
                            // スタンプアートの場合（スタンプアートリストに入れていく。)
                            
                        }
                    }*/
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullMyStickScript実行に失敗:\(error)")
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
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
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        // TODO: ログアウト処理
        // LogoutLogicインスタンス生成
        let logoutLogic = LogoutLogic()
        // ログアウト処理実行
        let bool = logoutLogic.logout()
        
        if bool == true{
            // トップ画面に遷移
            performSegue(withIdentifier: "logout", sender: nil)
        }else{
            print("ログアウトに失敗しました。")
        }
 
    }
    @IBAction func helpButtonAction(_ sender: Any) {
        //ヘルプ画面へ遷移
        performSegue(withIdentifier:"Help", sender: nil)
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
        
        // コレクションビューを更新
        print("コレクションビューを更新")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.myStickCollectionView.reloadData()
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
                self.myStickCollectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userTable"{
            // 遷移先ViewControllerの取得
            let userTableViewController = segue.destination as! UserTableViewController
            
            // プロフィール画面にユーザー情報を渡す
            userTableViewController.userId = self.user?.objectId
            let category = sender as? Int
            userTableViewController.category = category
        }
    }
 }
