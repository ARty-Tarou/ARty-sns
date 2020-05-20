//
//  SearchViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/22.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var leftCollectionView: UICollectionView!
    @IBOutlet weak var rightCollectionView: UICollectionView!
    
    // カレントユーザー
    let currentUser = NCMBUser.currentUser
    
    // スタンプリスト
    var stamps: [(Stamp, User)] = []
    var stampArts: [(Stamp, User)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionViewの設定
        leftCollectionView.register(UINib(nibName: "SearchStickCell", bundle: nil), forCellWithReuseIdentifier: "searchStickCell")
        rightCollectionView.register(UINib(nibName: "SearchStickCell", bundle: nil), forCellWithReuseIdentifier: "searchStickCell")
        leftCollectionView.delegate = self
        rightCollectionView.delegate = self
        leftCollectionView.dataSource = self
        rightCollectionView.dataSource = self
        
        // Cellのレイアウトを設定
        let leftLayout = UICollectionViewFlowLayout()
        let rightLayout = UICollectionViewFlowLayout()
        leftLayout.itemSize = CGSize(width: 182, height: 290)
        rightLayout.itemSize = CGSize(width: 182, height: 290)
        leftCollectionView.collectionViewLayout = leftLayout
        rightCollectionView.collectionViewLayout = rightLayout
        
        
        // デリゲートを設定
        searchTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Codable
    
    struct PullStickResult: Codable{
        // StickData
        let result: [StickDetailData]
        // skip
        let skip: Int
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
    
    // MARK: Method
    
    // 検索する文字列
    var searchWord: String? = nil
    var stampSkip = 0
    var stampArtSkip = 0
    
    func pullSearchStampStick(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearchStampStick.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?]  = ["searchWord": searchWord, "skip": stampSkip, "currentUserId": currentUser?.objectId]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchStampScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(PullStickResult.self, from: data!)
                    
                    self.stampSkip = json.skip
                    
                    print("stamp件数:\(json.result.count)件")
                    
                    // 取得した件数だけ回します
                    for stick in json.result{
                        // スタンプ、ユーザーインスタンスを生成
                        let stamp: Stamp = Stamp()
                        let user: User = User()
                        
                        // スタンプ・スタンプアートに関する情報を入れていく
                        let stickData = stick.stickData
                        
                        // 投稿の内容を代入
                        stamp.setUserId(userId: stickData.userId)
                        stamp.setDetail(detail: stickData.detail)
                        stamp.setNumberOfGood(numberOfGood: stickData.good)
                        stamp.setNumberOfViews(numberOfViews: stickData.numberOfViews)
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
                                
                                // コレクションビューを更新
                                print("コレクションビューを更新")
                                DispatchQueue.global().async {
                                    DispatchQueue.main.async {
                                        self.leftCollectionView.reloadData()
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
                        self.stamps.append((stamp,user))

                        // コレクションビューを更新
                        print("コレクションビューを更新")
                        DispatchQueue.global().async{
                            DispatchQueue.main.async {
                                self.leftCollectionView.reloadData()
                            }
                        }
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullSearchStampScript実行に失敗:\(error)")
            }
        })
    }
    
    
    func pullSearchStampArtStick(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearchStampArtStick.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["searchWord": searchWord, "skip": stampArtSkip]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchStampArtStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    
                }catch{
                    print("error")
                }
            case let .failure(error):
                print("pullSearchStampArtStickScript実行に失敗:\(error)")
            }
        })
    }
    
    // MARK: Action
    @IBAction func searchButtonAction(_ sender: Any) {
        if searchTextField.text == ""{
            print("検索文字列が入力されてないよ")
        }else{
            // スタンプ・スタンプアートリストを初期化
            stamps = []
            stampArts = []
            
            print("検索するよ:\(String(describing: searchTextField.text))")
            searchWord = searchTextField.text
            stampSkip = 0
            stampArtSkip = 0
            pullSearchStampStick()
            pullSearchStampArtStick()
        }
    }
    
    @objc func onStampGoodButton(_ sender: UIButton){
        print("タップされたstampGoodButtonのtag:\(sender.tag)")
        
        // TODO:すでにグッドされているか判定→されていなかったらグッドするよ処理をする
        // TODO:されていたらグッドやめるよ処理をする
        
    }
    
    @objc func onStampArtGoodButton(_ sender: UIButton){
        print("タップされたstampArtGoodButtonのtag:\(sender.tag)")
        
        // TODO:すでにグッドされているか判定→されていなかったらグッドするよ処理をする
        // TODO:されていたらグッドやめるよ処理をする
    }
    
    @objc func onStampUserIconButton(_ sender: UIButton){
        // 確認
        print("タップされたuserIconButtonのtag:\(sender.tag)")
        print("タップされたアイコンのuserId:\(String(describing: self.stamps[sender.tag].1.getUserId()))")
        
        // プロフィール画面へ遷移
        performSegue(withIdentifier: "profile", sender: self.stamps[sender.tag].1)
        
    }
    
    @objc func onStampArtUserIconButton(_ sender: UIButton){
        print("タップされたuserIconButtonのtag:\(sender.tag)")
        
        // プロフィール画面に遷移するよ
    }
    
    // MARK: UITextField
    
    // テキストフィールドでリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchStickCell", for: indexPath) as! SearchStickCell
        
        // セルに情報を付加
        if collectionView == leftCollectionView{
            // Stampのセル
            // セルに情報を付加
            cell.userName.text = stamps[indexPath.row].1.getUserName()
            if let userIcon = self.stamps[indexPath.row].1.getUserIconImage(){
                cell.userIconButton.setImage(userIcon, for: .normal)
            }
            if let stampImage = self.stamps[indexPath.row].0.getStampImage(){
                cell.stickImageView.image = stampImage
            }
            cell.detailTextView.text = self.stamps[indexPath.row].0.getDetail()
            cell.numberOfGood.text = String(self.stamps[indexPath.row].0.getNumberOfGood()!)
            
            // goodButtonにタグを設定し、アクションを追加
            cell.goodButton.tag = indexPath.row
            cell.goodButton.addTarget(self, action:  #selector(self.onStampGoodButton(_:)), for: .touchUpInside)
            
            // userIconButtonにタグを設定し、アクションを追加
            cell.userIconButton.tag = indexPath.row
            cell.userIconButton.addTarget(self, action: #selector(self.onStampUserIconButton(_:)), for: .touchUpInside)
            
        }else{
            // StampArtのセル
            
        }
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == leftCollectionView{
            // Stampのセル
            return stamps.count
        }else{
            // Stampのセル
            return stampArts.count
        }
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
