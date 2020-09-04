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
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // タイムラインリスト
    var timelineList: [(Stamp, User)] = []
    
    // goodが押された回数
    var timelineGoodCount: [Int] = []
    
    // 何件読んだか
    var skip = 0
    
    // 追加取得可能か
    var updateIsEnable = false
    
    // ar画面に渡すfileName
    var fileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ユーザー情報をセット
        userNameLabel.text = appDelegate.currentUser?.getUserName()
        
        // CollectionViewの設定
        collectionView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellWithReuseIdentifier: "timelineCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Cellのレイアウトを設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 370, height: 678)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        // タイムラインを取得
        self.pullTimeline()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // GoodCountを初期化
        timelineGoodCount = [Int](repeating: 0, count: timelineList.count)
    }
    
        override func viewWillDisappear(_ animated: Bool) {
        // 画面遷移するときに実行
        let goodLogic = GoodLogic()
        
        var index = 0
        for count in timelineGoodCount{
            if count % 2 == 1{
                // Good処理を行う
                let objectId = timelineList[index].0.getObjectId()
                let bool = timelineList[index].0.getGood()
                if bool == true{
                    goodLogic.pushGood(objectId: objectId!)
                }else if bool == false{
                    goodLogic.undoGood(objectId: objectId!)
                }
            }
            index += 1
        }
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
        // 投稿のobjectId
        let objectId: String
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
        let fileName: String?
    }
    
    struct UserDetailData: Codable{
        // 投稿者のユーザーID
        let userId: String
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
        print("currentUser:\(String(describing: currentUser.objectId))")
        let requestBody: [String: Any?] = ["userId": currentUser.objectId, "skip": skip]
        
        // スクリプト実行
        // タイムラインを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullTimelineScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode(PullStickResult.self, from: data!)
                    
                    self.skip += json.skip
                    
                    print("timeline件数:\(json.result.count)")
                    
                    // Good押されましたカウントを追加
                    for _ in 0..<json.result.count {
                        self.timelineGoodCount.append(0)
                    }
                    
                    // timelineListを作成していく
                    for timelineData in json.result{
                        // スタンプ、ユーザーインスタンスを生成
                        let stamp: Stamp = Stamp()
                        let user: User = User()
                        
                        // スタンプ・スタンプアートに関する情報を入れていく
                        let stickData = timelineData.stickData
                        
                        // 投稿の内容を代入
                        stamp.setObjectId(objectId: stickData.objectId)
                        stamp.setUserId(userId: stickData.userId)
                        stamp.setDetail(detail: stickData.detail)
                        stamp.setNumberOfGood(numberOfGood: stickData.good)
                        stamp.setNumberOfViews(numberOfViews: stickData.numberOfViews)
                        
                        // スタンプか、arか
                        stamp.setType(type: stickData.stamp)
                        
                        // カレントユーザーがこの投稿をGoodしているか
                        stamp.setGood(good: timelineData.good)
                        
                        // ファイル名を代入
                        stamp.setFileName(fileName: stickData.staticData.fileName!)
                        // ファイルストアから画像ファイルを取得
                        let file = NCMBFile(fileName: stamp.getFileName()!)
                        file.fetchInBackground(callback: {result in
                            switch result{
                            case let .success(data):
                                print("画像取得に成功\(file.fileName)")
                                
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
    
    func goodButtonLayout(button: UIButton, bool: Bool?){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if bool == true{
                    button.setImage(UIImage(named: "gooded"), for: .normal)
                }else{
                    button.setImage(UIImage(named: "good"), for: .normal)
                }
            }
        }
    }
    
    // MARK: Action
    @IBAction func stickButtonAction(_ sender: Any) {
        // 投稿フォーム画面に遷移
        performSegue(withIdentifier: "stick", sender: nil)
    }
    
    @IBAction func artButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "art", sender: nil)
    }
    
    @IBAction func reloadButtonAction(_ sender: Any) {
        // リロードボタンが押されたとき
        // skipを初期化する
        self.skip = 0
        
        // タイムラインリスト、グッドカウントを初期化
        timelineList = []
        timelineGoodCount = []
        
        // コレクションビューを更新
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // コレクションビューを更新
                print("コレクションビューを更新")
                self.collectionView.reloadData()
            }
        }
        
        // Stickを取得する
        pullTimeline()
    }
    
    
    @objc func onGoodButton(_ sender: UIButton){
        print("タップされたGoodButtonのtag:\(sender.tag)")
        print("タイムラインの配列の要素数:\(timelineList.count)")
        print("タップされたGoodButtonのStickId:\(String(describing: timelineList[sender.tag].0.getObjectId()))")
        
        // 元々Goodしているか取得
        let bool = timelineList[sender.tag].0.getGood()!
        
        // Goodしているか情報を更新
        timelineList[sender.tag].0.setGood(good: !bool)
        
        // ボタンのレイアウトを変更
        goodButtonLayout(button: sender, bool: !bool)
        
        // Goodが押された回数をカウント
        self.timelineGoodCount[sender.tag] += 1
        print("timelineGoodCount[\(sender.tag)]:\(timelineGoodCount[sender.tag])")
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
        cell.numberOfGood.text = String(self.timelineList[indexPath.row].0.getNumberOfGood()!)
        
        // goodButtonを設定
        goodButtonLayout(button: cell.goodButton, bool: self.timelineList[indexPath.row].0.getGood())
        cell.goodButton.tag = indexPath.row
        cell.goodButton.addTarget(self, action:  #selector(self.onGoodButton(_:)), for: .touchUpInside)
        
        // userIconButtonを設定
        cell.userIconButton.tag = indexPath.row
        cell.userIconButton.addTarget(self, action: #selector(self.onUserIcon(_ :)), for: .touchUpInside)
        
        // 最後まで追加終了したら追加取得可能にする
        if indexPath.row == timelineList.count - 1 {
            print("タイムラインセル追加したよ")
            updateIsEnable = true
        }
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timelineList.count
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        // activityIndicatorを表示、入力不可にする
        let activityIndicatorLogic = ActivityIndicatorLogic(view: view)
        activityIndicatorLogic.startActivityIndecator(view: view)
        
        // indexPath.rowから選択されたセルを取得
        print(timelineList[indexPath.row].0.getFileName()!)
        
        
        // 選択されたセルがarのデータのとき、AR画面へ遷移するときの処理
        if timelineList[indexPath.row].0.getType() == false {
            
            // worldMap名を取得
            var worldMapName = timelineList[indexPath.row].0.getFileName()!
            worldMapName = String(worldMapName.suffix(worldMapName.count - 2))
            worldMapName = "a." + worldMapName
            
            // arDataを取得
            let pullARDataLogic = PullARDataLogic()
            pullARDataLogic.pullARData(worldMapName: worldMapName)
            
            // activityIndicatorを終了
            activityIndicatorLogic.stopActivityIndecator(view: self.view)
            
            self.fileName = worldMapName
            performSegue(withIdentifier: "art", sender: nil)
        }
    }
    
    // スクロールされたとき
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 最後までスクロールされたか
        if collectionView.contentOffset.x + collectionView.frame.size.width > collectionView.contentSize.width && collectionView.isDragging && updateIsEnable {
            print("一番最後にきたよ:\(updateIsEnable)")
            // 追加のタイムラインを取得
            pullTimeline()
            
            // 一時的に更新不可能にする
            updateIsEnable = false

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profile"{
            // 遷移先ViewControllerの取得
            let profileViewController = segue.destination as! ProfileViewController
            
            // プロフィール画面にユーザー情報を渡す
            let user = sender as? User
            profileViewController.user = user
        } else if segue.identifier == "art" {
            
            // 遷移先viewControllerの取得
            let artViewController = segue.destination as! ArtViewController
            
            // ファイルネームを渡す
            artViewController.fileName = self.fileName
        }
    }
}
