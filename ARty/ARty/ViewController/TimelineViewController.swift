//
//  TimelineViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    // スタンプリスト
    var timelineList: [(Stamp)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionViewの設定
        collectionView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellWithReuseIdentifier: "timelineCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Cellのレイアウトを設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 370, height: 745)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        // タイムラインを取得
        self.pullTimeline()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: JSON
    struct StickData: Codable{
        // この投稿のgood数
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
    
    struct UserInfo: Codable{
        // ユーザーアイコンのファイル名
        let iconImageName: String?
        // ユーザーデータ
        let userData: UserData?
    }
    
    struct UserData: Codable{
        // ユーザー名
        let userName: String?
    }
    
    // MARK: Methods
    // スクリプト
    func pullTimeline(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullTimeline.js", method: .post)
        
        // ボディを設定
        guard let user = NCMBUser.currentUser else{
            fatalError("カレントユーザーが取得できなかったよ")
        }
        let requestBody: [String: Any?] = ["userId": user.objectId]
        
        // スクリプト実行
        // JSON形式でタイムラインを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullTimelineScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode([StickData].self, from: data!)
                    
                    // 取得したjsonのデータ数だけ回す
                    for stick in json{
                        // スタンプインスタンスを生成
                        let stamp: Stamp = Stamp()
                        stamp.setUserId(userId: stick.userId!)
                        stamp.setGood(good: stick.good!)
                        
                        if stick.stamp == true{
                            // スタンプの場合
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
                                        print("画像取得に成功")
                                        // データを画像に変換
                                        if let image = data.flatMap(UIImage.init){
                                            // スタンプに画像をセット
                                            print("画像をセット:\(stampData.stampName!)")
                                            stamp.setStampImage(stampImage: image)
                                            
                                            // コレクションビューを更新
                                            print("コレクションビューを更新")
                                            DispatchQueue.global().async{
                                                DispatchQueue.main.async {
                                                    self.collectionView.reloadData()
                                                }
                                            }
                                            
                                        }
                                    case let .failure(error):
                                        print("画像取得に失敗:\(error)")
                                    }
                                })
                            }
                            
                            // ユーザー情報を取得
                            // スクリプトインスタンスを生成
                            let script = NCMBScript(name: "pullYourInform.js", method: .post)
                            
                            // スクリプトボディを設定
                            let requestBody: [String: Any?] = ["userId": stick.userId!]
                            
                            // スクリプトを実行
                            script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                                switch result{
                                case let .success(data):
                                    print("pullYourInformScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                                    
                                    do{
                                        let decoder = JSONDecoder()
                                        
                                        let json = try decoder.decode([UserInfo].self, from: data!)
                                        
                                        for userInfo in json{
                                            if let userData = userInfo.userData{
                                                // ユーザー名をセット
                                                stamp.setUserName(userName: userData.userName!)
                                            }
                                            
                                            // ファイルストアからユーザーアイコンを取得
                                            print("ユーザーアイコンを取ってきます:\(userInfo.iconImageName!)")
                                            let file = NCMBFile(fileName: userInfo.iconImageName!)
                                            file.fetchInBackground(callback: {result in
                                                switch result{
                                                case let .success(data):
                                                    print("ユーザーアイコン取得に成功")
                                                    
                                                    // データを画像に変換
                                                    if let image = data.flatMap(UIImage.init){
                                                        // ユーザーアイコンをセット
                                                        stamp.setUserIcon(userIcon: image)
                                                    }
                                                    
                                                    // コレクションビューを更新
                                                    print("コレクションビューを更新")
                                                    DispatchQueue.global().async{
                                                        DispatchQueue.main.async {
                                                            self.collectionView.reloadData()
                                                        }
                                                    }
                                                case let .failure(error):
                                                    print("ユーザーアイコン取得に失敗:\(error)")
                                                }
                                            })
                                            
                                            // コレクションビューを更新
                                            print("コレクションビューを更新")
                                            DispatchQueue.global().async{
                                                DispatchQueue.main.async {
                                                    self.collectionView.reloadData()
                                                }
                                            }
                                        }
                                        
                                    }catch{
                                        print("error")
                                    }
                                case let .failure(error):
                                    print("pullYourInformScript実行に失敗:\(error)")
                                }
                            })
                        }else{
                            // スタンプアートの場合
                            
                        }
                        
                        // ユーザー情報の取得処理
                        // タイムラインリストに追加
                        self.timelineList.append(stamp)
                        
                        // コレクションビューを更新
                        print("コレクションビューを更新")
                        DispatchQueue.global().async{
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullTimelineScript実行に失敗:\(error)")
            }
        })
        
    }
    
    // MARK: Action
    @IBAction func stickButtonAction(_ sender: Any) {
        // 投稿フォーム画面に遷移
        performSegue(withIdentifier: "stick", sender: nil)
    }
    
    @objc func onUserIcon(_ sender: UIButton){
        // ボタンのタグを表示
        print("ユーザーアイコンが押されたよ:\(sender.tag)")
        print("タップされたアイコンのuserId:\(self.timelineList[sender.tag].userId!)")
        
        // プロフィール画面に渡すユーザーインスタンスを作成
        let user = User()
        if let userId = self.timelineList[sender.tag].userId{
            user.setUserId(userId: userId)
        }
        if let userName = self.timelineList[sender.tag].userName{
            user.setUserName(userName: userName)
        }
        if let userIconImage = self.timelineList[sender.tag].userIcon{
            user.setUserIconImage(userIconImage: userIconImage)
        }
        
        // プロフィール画面へ遷移
        performSegue(withIdentifier: "profile", sender: user)
    }
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timelineCell", for: indexPath) as! TimelineCell
        
        // セルに情報を付加
        cell.userNameLabel.text = self.timelineList[indexPath.row].userName
        if let userIcon = self.timelineList[indexPath.row].userIcon{
            cell.userIconButton.setImage(userIcon, for: .normal)
        }
        if let stampImage = self.timelineList[indexPath.row].stampImage{
            cell.stampImageView.image = stampImage
        }
        cell.goodNum.text = String(self.timelineList[indexPath.row].good!)
        
        // セルのボタンにアクションを設定
        cell.userIconButton.tag = indexPath.row
        cell.userIconButton.addTarget(self, action: #selector(self.onUserIcon(_ :)), for: .touchUpInside)
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timelineList.count
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        // indexPath.rowから選択されたセルを取得
        print(timelineList[indexPath.row].stampName ?? nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profile"{
            // 遷移先ViewControllerの取得
            let profileViewController = segue.destination as! ProfileViewController
            
            // プロフィール画面にユーザー情報を渡す
            let user = sender as? User
            profileViewController.user = user
        }
    }
}
