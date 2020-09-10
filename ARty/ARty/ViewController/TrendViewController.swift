//
//  TrendViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class TrendViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Properties
    @IBOutlet weak var leftCollectionView: UICollectionView!
    @IBOutlet weak var rightCollectionView: UICollectionView!
    
    // カレントユーザー
    let currentUser = NCMBUser.currentUser
    
    // スタンプリスト
    var stampList: [(Stamp, User)] = []
    var stampArtList: [(Stamp, User)] = []
    
    // Goodが押された回数
    var stampGoodCount: [Int] = []
    var stampArtGoodCount: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // CollectionViewの設定
        leftCollectionView.register(UINib(nibName: "SearchStickCell", bundle: nil), forCellWithReuseIdentifier: "searchStickCell")
        rightCollectionView.register(UINib(nibName: "SearchStickCell", bundle: nil), forCellWithReuseIdentifier: "searchStickCell")
        leftCollectionView.delegate = self
        rightCollectionView.delegate = self
        leftCollectionView.dataSource = self
        rightCollectionView.dataSource = self
        
        // トレンドを取得
        pullStampTrend()
        pullStampArtTrend()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // GoodCountを初期化
        stampGoodCount = [Int](repeating: 0, count: stampList.count)
        stampArtGoodCount = [Int](repeating: 0, count: stampArtList.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 画面遷移するときに実行
        let goodLogic = GoodLogic()
        
        // スタンプ
        var index = 0
        for count in stampGoodCount{
            if count % 2 == 1{
                // Good処理を行う
                let objectId = stampList[index].0.getObjectId()
                let bool = stampList[index].0.getGood()
                if bool == true{
                    goodLogic.pushGood(objectId: objectId!)
                }else if bool == false{
                    goodLogic.undoGood(objectId: objectId!)
                }
            }
            index += 1
        }
        
        // スタンプアート
        index = 0
        for count in stampArtGoodCount {
            if count % 2 == 1 {
                // Good処理を行う
                let objectId = stampArtList[index].0.getObjectId()
                let bool = stampArtList[index].0.getGood()
                if bool == true {
                    goodLogic.pushGood(objectId: objectId!)
                }else if bool == false {
                    goodLogic.undoGood(objectId: objectId!)
                }
            }
            index += 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // レイアウト
        leftCollectionView.contentSize.width = (UIScreen.main.bounds.width - 37) / 2
        
        
        // Cellのレイアウトを設定
        let leftLayout = UICollectionViewFlowLayout()
        let rightLayout = UICollectionViewFlowLayout()
        leftLayout.itemSize = CGSize(width: 182, height: 290)
        rightLayout.itemSize = CGSize(width: 182, height: 290)
        leftCollectionView.collectionViewLayout = leftLayout
        rightCollectionView.collectionViewLayout = rightLayout
    }
    
    // MARK: Codable
    struct PullStickResult: Codable{
        // StickData
        let result: [StickDetailData]
    }
    
    struct StickDetailData: Codable{
        // 投稿のデータ
        let stickData: StickData
        // 投稿に対するユーザーのデータ
        let userDetailData: UserDetailData
        // フォローしているか
        let follow: Bool
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
    
    // MARK: Method
    func pullStampTrend(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullStampTrend.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": currentUser?.objectId]
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullStampTrendScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                // スタンプリストをセット
                self.setStampList(data: data!, type: 0)
                
            case let .failure(error):
                print("pullStampTrendScript実行に失敗:\(error)")
            }
        })
    }
    
    func pullStampArtTrend(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullStampArtTrend.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["userId": currentUser?.objectId]
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullStampArtTrendScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                // スタンプリストをセット
                self.setStampList(data: data!, type: 1)
                
            case let .failure(error):
                print("pullStampArtTrendScript実行に失敗:\(error)")
            }
        })
    }
    
    // スタンプリストに代入していく
    func setStampList(data: Data, type: Int) {
        
        do {
            let decoder = JSONDecoder()
            let json = try decoder.decode(PullStickResult.self, from: data)
            
            print("stamp件数:\(json.result.count)件")
            
            // Good押されましたカウントを初期化
            if type == 0 {
                // スタンプ
                self.stampGoodCount = [Int](repeating: 0, count: json.result.count)
            } else {
                // スタンプアート
                self.stampArtGoodCount = [Int](repeating: 0, count: json.result.count)
            }
            
            // 取得した件数だけ回します
            for stick in json.result {
                // スタンプ、ユーザーインスタンスを生成
                let stamp: Stamp = Stamp()
                let user: User = User()
                
                // スタンプ・スタンプアートに関する情報を入れていく
                let stickData = stick.stickData
                
                // 投稿の内容を代入
                stamp.setObjectId(objectId: stickData.objectId)
                stamp.setUserId(userId: stickData.userId)
                stamp.setDetail(detail: stickData.detail)
                stamp.setNumberOfGood(numberOfGood: stickData.good)
                stamp.setNumberOfViews(numberOfViews: stickData.numberOfViews)
                stamp.setFileName(fileName: stickData.staticData.fileName!)
                
                if type == 0 {
                    // スタンプ
                    stamp.setType(type: true)
                } else {
                    // スタンプアート
                    stamp.setType(type: false)
                }
                
                // カレントユーザーがこの投稿をGoodしているか
                stamp.setGood(good: stick.good)
                
                // ファイルストアからスタンプを取得
                let file = NCMBFile(fileName: stamp.getFileName()!)
                file.fetchInBackground(callback: {result in
                    switch result{
                    case let .success(data):
                        print("スタンプ画像取得に成功\(file.fileName)")
                        
                        // データをUIImageに変換
                        let image = data.flatMap(UIImage.init)
                        // スタンプに画像を代入
                        stamp.setStampImage(stampImage: image)
                        
                        // コレクションビューを更新
                        if type == 0 {
                            print("コレクションビューを更新")
                            DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    self.leftCollectionView.reloadData()
                                }
                            }
                        } else {
                            print("コレクションビューを更新")
                            DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    self.rightCollectionView.reloadData()
                                }
                            }
                        }
                        
                    case let .failure(error):
                        print("スタンプ画像取得に失敗:\(error)")
                    }
                })
                
                // ユーザーに関する情報を入れていく
                let userDetailData = stick.userDetailData
                
                // ユーザー情報を代入
                user.setUserId(userId: userDetailData.userId)
                user.setUserName(userName: userDetailData.userData.userName)
                user.setSelfIntroduction(selfIntroduction: userDetailData.selfIntroduction)
                user.setNumberOfFollowed(numberOfFollowed: userDetailData.numberOfFollowed)
                user.setNumberOfFollow(numberOfFollow: userDetailData.numberOfFollow)
                user.setFollow(bool: stick.follow)
                
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
                                    self.leftCollectionView.reloadData()
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
                
                // スタンプリストに追加
                if type == 0 {
                    // スタンプ
                    self.stampList.append((stamp, user))
                    
                    // コレクションビューを更新
                    print("コレクションビューを更新")
                    DispatchQueue.global().async{
                        DispatchQueue.main.async {
                            self.leftCollectionView.reloadData()
                        }
                    }
                } else {
                    // スタンプアート
                    self.stampArtList.append((stamp, user))
                    
                    // コレクションビューを更新
                    print("コレクションビューを更新")
                    DispatchQueue.global().async{
                        DispatchQueue.main.async {
                            self.rightCollectionView.reloadData()
                        }
                    }
                }
                
            }
        } catch {
            print("error")
        }
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
        // スタンプリストを初期化
        stampList = []
        stampArtList = []
        
        // コレクションビューを更新
        print("コレクションビューを更新")
        DispatchQueue.global().async{
            DispatchQueue.main.async {
                self.leftCollectionView.reloadData()
                self.rightCollectionView.reloadData()
            }
        }
        
        
        // Stickを取得
        pullStampTrend()
        pullStampArtTrend()
    }
    
    
    @objc func onStampGoodButton(_ sender: UIButton){
        print("タップされたstampGoodButtonのtag:\(sender.tag)")
        print("タップされたGoodButtonのobjectId:\(String(describing: stampList[sender.tag].0.getObjectId()))")
        
        // 元々Goodしているか取得
        let bool = stampList[sender.tag].0.getGood()!
        
        // Goodしているか情報を更新
        stampList[sender.tag].0.setGood(good: !bool)
        
        // ボタンのレイアウトを変更
        goodButtonLayout(button: sender, bool: !bool)
        
        // Goodが押された回数をカウント
        self.stampGoodCount[sender.tag] += 1
        print("stampGoodCount[\(sender.tag)]:\(stampGoodCount[sender.tag])")
     }
     
     @objc func onStampArtGoodButton(_ sender: UIButton){
         print("タップされたstampArtGoodButtonのtag:\(sender.tag)")
         print("タップされたGoodButtonのobjectId:\(String(describing: stampArtList[sender.tag].0.getObjectId()))")
         
         // 元々Goodしているか取得
         let bool = stampArtList[sender.tag].0.getGood()!
         
         // Goodしているか情報を更新
         stampArtList[sender.tag].0.setGood(good: !bool)
         
         // ボタンのレイアウトを変更
         goodButtonLayout(button: sender, bool: !bool)
         
         // Goodが押された回数をカウント
         self.stampArtGoodCount[sender.tag] += 1
         print("stampArtGoodCount[\(sender.tag)]:\(stampArtGoodCount[sender.tag])")
     }
     
     @objc func onStampUserIconButton(_ sender: UIButton){
         // 確認
         print("タップされたuserIconButtonのtag:\(sender.tag)")
         print("タップされたアイコンのuserId:\(String(describing: self.stampList[sender.tag].1.getUserId()))")
         
         // プロフィール画面へ遷移
         performSegue(withIdentifier: "profile", sender: self.stampList[sender.tag].1)
         
    }
    
    @objc func onStampArtUserIconButton(_ sender: UIButton){
        print("タップされたuserIconButtonのtag:\(sender.tag)")
        print("タップされたアイコンのuserId:\(String(describing: self.stampArtList[sender.tag].1.getUserId()))")
        
        // プロフィール画面に遷移するよ
        performSegue(withIdentifier: "profile", sender: self.stampArtList[sender.tag].1)
    }
    
    // MARK: UICollectionViewDataSource
    
       // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchStickCell", for: indexPath) as! SearchStickCell
        
        // セルに情報を付加
        if collectionView == leftCollectionView{
            // Stampのセル
            // セルに情報を付加
            cell.userName.text = stampList[indexPath.row].1.getUserName()
            if let userIcon = self.stampList[indexPath.row].1.getUserIconImage(){
                cell.userIconButton.setImage(userIcon, for: .normal)
            }
            if let stampImage = self.stampList[indexPath.row].0.getStampImage(){
                cell.stickImageView.image = stampImage
            }
            cell.detailTextView.text = self.stampList[indexPath.row].0.getDetail()
            cell.numberOfGood.text = String(self.stampList[indexPath.row].0.getNumberOfGood()!)
            
            // goodButtonを設定
            goodButtonLayout(button: cell.goodButton, bool: self.stampList[indexPath.row].0.getGood())
            cell.goodButton.tag = indexPath.row
            cell.goodButton.addTarget(self, action:  #selector(self.onStampGoodButton(_:)), for: .touchUpInside)
            
            // userIconButtonを設定
            cell.userIconButton.tag = indexPath.row
            cell.userIconButton.addTarget(self, action: #selector(self.onStampUserIconButton(_:)), for: .touchUpInside)
            
        }else{
            // StampArtのセル
            // セルに情報を付加
            cell.userName.text = stampArtList[indexPath.row].1.getUserName()
            if let userIcon = self.stampArtList[indexPath.row].1.getUserIconImage(){
                cell.userIconButton.setImage(userIcon, for: .normal)
            }
            if let stampImage = self.stampArtList[indexPath.row].0.getStampImage(){
                cell.stickImageView.image = stampImage
            }
            cell.detailTextView.text = self.stampArtList[indexPath.row].0.getDetail()
            cell.numberOfGood.text = String(self.stampArtList[indexPath.row].0.getNumberOfGood()!)
            
            // goodButtonを設定
            goodButtonLayout(button: cell.goodButton, bool: self.stampArtList[indexPath.row].0.getGood())
            cell.goodButton.tag = indexPath.row
            cell.goodButton.addTarget(self, action:  #selector(self.onStampArtGoodButton(_:)), for: .touchUpInside)
            
            // userIconButtonを設定
            cell.userIconButton.tag = indexPath.row
            cell.userIconButton.addTarget(self, action: #selector(self.onStampArtUserIconButton(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == leftCollectionView{
            // Stampのセル
            return stampList.count
        }else{
            // StampArtのセル
            return stampArtList.count
        }
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == leftCollectionView {
            // スタンプ
            
            // セルを取得
            print(stampList[indexPath.row].0.getFileName()!)
        } else {
            // スタンプアート
            
            // セルを取得
            print(stampArtList[indexPath.row].0.getFileName()!)
        }
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
