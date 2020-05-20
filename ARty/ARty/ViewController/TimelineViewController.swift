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
    
    // タイムラインリスト
    var timelineList: [(Stamp, User)] = []
    
    
    // 何件読んだか
    var skip = 0
    
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
    
    // MARK: Codable
    
    struct PullStickResult: Codable{
        // TimelineData
        let result: [TimelineData]
        // skip
        let skip: Int
    }
    
    struct TimelineData: Codable{
        // 投稿のデータ
        let stickData: StickData
        // 投稿に対するユーザーのデータ
        let userDetailData: UserDetailData
        // グッドしているか
        let good: Bool
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
        let staticData: StickStaticData
    }
    
    struct StickStaticData: Codable{
        // スタンプ名
        let stampName: String?
        // TODO: 後々ここにスタンプアート名を書くのかな？ let stampArtName: String?
    }
    
    struct UserDetailData: Codable{
        // 投稿者のユーザーID
        let userId: String
        // TODO: 投稿者の誕生日（後々Date型に変更？)
        let birthday: String?
        // 投稿者のユーザーアイコンのファイル名
        let iconImageName: String
        // 投稿者のプロフィールコメント
        let selfIntroduction: String
        // ユーザーのフォロワー数
        let numberOfFollowed: Int
        // ユーザーのフォロー数
        let numberOfFollow: Int
        // ユーザーのその他情報
        let userData: UserData
    }
    
    struct UserData: Codable{
        // ユーザー名
        let userName: String
    }
    
    // MARK: Methods
    // スクリプト
    func pullTimeline(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullTimeline.js", method: .post)
        
        // ボディを設定
        guard let currentUser = NCMBUser.currentUser else{
            fatalError("カレントユーザーが取得できなかったよ")
        }
        print("currentUser:\(currentUser.objectId)")
        let requestBody: [String: Any?] = ["userId": currentUser.objectId]
        
        // スクリプト実行
        // JSON形式でタイムラインを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullTimelineScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode(PullStickResult.self, from: data!)
                    
                    self.skip = json.skip
                    
                    // timelineListを作成していく
                    for timelineData in json.result{
                        // スタンプ、ユーザーインスタンスを生成
                        let stamp: Stamp = Stamp()
                        let user: User = User()
                        
                        // スタンプ・スタンプアートに関する情報を入れていく
                        let stickData = timelineData.stickData
                        
                        // 投稿の内容を代入
                        stamp.setUserId(userId: stickData.userId)
                        stamp.setDetail(detail: stickData.detail)
                        stamp.setNumberOfGood(numberOfGood: stickData.good)
                        stamp.setNumberOfViews(numberOfViews: stickData.numberOfViews)
                        
                        // スタンプか、スタンプアートか
                        if stickData.stamp == true{
                            // スタンプ名を代入
                            stamp.setStampName(stampName: stickData.staticData.stampName!)
                            // ファイルストアからスタンプを取得
                            let file = NCMBFile(fileName: stamp.getStampName()!)
                            file.fetchInBackground(callback: {result in
                                switch result{
                                case let .success(data):
                                    print("スタンプ画像取得に成功\(file.fileName)")
                                    
                                    // データをUIImageに変換
                                    let image = data.flatMap(UIImage.init)
                                    // スタンプに画像を代入
                                    stamp.setStampImage(stampImage: image)
                                    
                                    // コレクションビューを更新
                                    print("コレクションビューを更新")
                                    DispatchQueue.global().async {
                                        DispatchQueue.main.async {
                                            self.collectionView.reloadData()
                                        }
                                    }
                                    
                                case let .failure(error):
                                    print("スタンプ画像取得に失敗\(error)")
                                }
                            })
                        }else{
                            // スタンプアート名を代入
                        }
                        
                        // ユーザーに関する情報を入れていく
                        let userDetailData = timelineData.userDetailData
                        
                        // ユーザー情報を代入
                        user.setUserId(userId: userDetailData.userId)
                        user.setUserName(userName: userDetailData.userData.userName)
                        user.setSelfIntroduction(selfIntroduction: userDetailData.selfIntroduction)
                        user.setNumberOfFollowed(numberOfFollowed: userDetailData.numberOfFollowed)
                        user.setNumberOfFollow(numberOfFollow: userDetailData.numberOfFollow)
                        user.setFollow(bool: true)
                        
                        // デフォルトアイコンではない場合ファイルストアからユーザーアイコンを取得する
                        if userDetailData.iconImageName != "firstIcon"{
                            let file = NCMBFile(fileName: userDetailData.iconImageName)
                            file.fetchInBackground(callback: {result in
                                switch result{
                                case let .success(data):
                                    print("ユーザーアイコン取得に成功:\(file.fileName)")
                                    
                                    // データをUIImageに変換
                                    let image = data.flatMap(UIImage.init)
                                    user.setUserIconImage(userIconImage: image!)
                                    
                                    // コレクションビューを更新
                                    print("コレクションビューを更新")
                                    DispatchQueue.global().async {
                                        DispatchQueue.main.async {
                                            self.collectionView.reloadData()
                                        }
                                    }
                                    
                                case let .failure(error):
                                    print("ユーザーアイコン取得に失敗:\(error)")
                                }
                            })
                        }else{
                            // 初期アイコンを設定
                            user.setUserIconImage(userIconImage: UIImage(named: "FirstIcon")!)
                        }
                        
                        // タイムラインリストに追加
                        self.timelineList.append((stamp, user))
                        
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
        print("タップされたアイコンのuserId:\(String(describing: self.timelineList[sender.tag].1.getUserId()))")
        
        // プロフィール画面へ遷移
        performSegue(withIdentifier: "profile", sender: self.timelineList[sender.tag].1)
    }
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timelineCell", for: indexPath) as! TimelineCell
        
        // セルに情報を付加
        cell.userNameLabel.text = self.timelineList[indexPath.row].1.getUserName()
        if let userIcon = self.timelineList[indexPath.row].1.getUserIconImage(){
            cell.userIconButton.setImage(userIcon, for: .normal)
        }
        if let stampImage = self.timelineList[indexPath.row].0.getStampImage(){
            cell.stampImageView.image = stampImage
        }
        cell.detailTextView.text = self.timelineList[indexPath.row].0.getDetail()
        cell.goodNum.text = String(self.timelineList[indexPath.row].0.getNumberOfGood()!)
        
        
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
        print(timelineList[indexPath.row].0.getStampName())
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
