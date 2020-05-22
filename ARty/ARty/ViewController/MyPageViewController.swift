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
    let currentUser = NCMBUser.currentUser
    var currentUserDetail: User?
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    // 何件読んだか
    var skip = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // userNameLabelにユーザー名を設定
        userNameLabel.text = currentUser?.userName
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: JSON
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
    
    struct SearchResult: Codable{
        // StickData
        let result: [StickData]
        // skip
        let skip: Int
    }
    
    struct PullStickResult: Codable{
        // StickData
        let result: [StickDetailData]
        // skip
        let skip: Int
    }
    
    struct StickDetailData: Codable{
        // 投稿のデータ
        let stickData: StickData
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
        let staticData: StaticData
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
        let requestBody:[String: Any?] = ["userId": self.currentUser?.objectId]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyInformScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                    let json = try decoder.decode([UserDetailData].self, from: data!)
                    
                    // ユーザーに関する情報を入れていく
                    let userDetailData = json.first
                    let user = User()
                    
                    // ユーザー情報を代入
                    user.setUserId(userId: userDetailData!.userId)
                    user.setUserName(userName: (userDetailData?.userData.userName)!)
                    user.setSelfIntroduction(selfIntroduction: userDetailData!.selfIntroduction)
                    user.setNumberOfFollowed(numberOfFollowed: userDetailData!.numberOfFollowed)
                    user.setNumberOfFollow(numberOfFollow: userDetailData!.numberOfFollow)
                    
                    self.currentUserDetail = user
                    
                    if userDetailData?.iconImageName != "firstIcon"{
                        let file = NCMBFile(fileName: userDetailData!.iconImageName)
                        file.fetchInBackground(callback: {result in
                            switch result{
                            case let .success(data):
                                print("ユーザーアイコン取得に成功:\(file.fileName)")
                                
                                // データをUIImageに変換
                                let image = data.flatMap(UIImage.init)
                                self.currentUserDetail?.setUserIconImage(userIconImage: image!)
                                
                                // userIconImageViewに反映
                                DispatchQueue.global().async {
                                    DispatchQueue.main.async {
                                        self.userIconImageView.image = image
                                    }
                                }
                                
                            case let .failure(error):
                                print("ユーザーアイコン取得に失敗:\(error)")
                            }
                        })
                    }else{
                        // 初期アイコンを設定
                        self.currentUserDetail?.setUserIconImage(userIconImage: UIImage(named: "FirstIcon")!)
                    }
                    
                    // 画面部品を更新
                    self.setUserDetail()
                    
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
        let requestBody: [String: Any?] = ["userId": self.currentUser?.objectId, "skip": skip]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(PullStickResult.self, from: data!)
                    
                    self.skip = json.skip
                    
                    // スタンプリストを作成していく
                    for stickDetailData in json.result{
                        
                        // スタンプインスタンスを生成
                        let stamp: Stamp = Stamp()
                        
                        // スタンプ・スタンプアートに関する情報を入れていく
                        let stickData = stickDetailData.stickData
                        
                        // 投稿の内容を代入
                        stamp.setObjectId(objectId: stickData.objectId)
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
                                            self.myStickCollectionView.reloadData()
                                        }
                                    }
                                    
                                case let .failure(error):
                                    print("スタンプ画像取得に失敗\(error)")
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
                        
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullMyStickScript実行に失敗:\(error)")
            }
        })
    }
    
    // 画面部品にユーザー情報を付与する
    func setUserDetail(){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.selfIntroductionTextView.text = self.currentUserDetail?.getSelfIntroduction()
                self.numberOfFollowLabel.text = String((self.currentUserDetail?.getNumberOfFollow())!)
                self.numberOfFollowerLabel.text = String((self.currentUserDetail?.getNumberOfFollowed())!)
            }
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
        performSegue(withIdentifier: "changeMyData", sender: nil)
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if stampTab.isEnabled == false{
            // スタンプの場合
            print(stamps[indexPath.row].getStampName())
        }else{
            // スタンプアートの場合
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userTable"{
            // 遷移先ViewControllerの取得
            let userTableViewController = segue.destination as! UserTableViewController
            
            // プロフィール画面にユーザー情報を渡す
            userTableViewController.userId = self.currentUser?.objectId
            let category = sender as? Int
            userTableViewController.category = category
        }else if segue.identifier == "changeMyData"{
            // 遷移先ViewControllerの取得
            let changeMyDataViewController = segue.destination as! ChangeMyDataViewController
            
            // ChangeMyDataにユーザー情報を渡す
            changeMyDataViewController.currentUserDetailData = self.currentUserDetail
            
        }
    }
 }
