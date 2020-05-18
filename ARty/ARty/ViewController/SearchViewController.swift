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
        
        // Do any additional setup after loading the view.
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
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
    
    // MARK: Codable
    
    struct JSONResult: Codable{
        // StickData
        let result: [StickData]
        // skip
        let skip: Int
    }
    
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
    
    struct UserAllData: Codable{
        // ユーザー
        let result: UserInfo?
        // フォロー情報
        let follow: Bool?
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
    
    // MARK: Method
    
    // 検索する文字列
    var searchWord: String? = nil
    var stampSkip: Int = 0
    var stampArtSkip: Int = 0
    func pullSearchStampStick(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearchStampStick.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?]  = ["searchWord": searchWord, "skip": stampSkip]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchStampScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                do{
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(JSONResult.self, from: data!)
                    
                    self.stampSkip = json.skip
                    
                    print("stamp件数:\(json.result.count)件")
                    
                    // 取得した件数だけ回します
                    for stick in json.result{
                        // スタンプ、ユーザーインスタンスを生成
                        let stamp: Stamp = Stamp()
                        let user: User = User()
                        user.setUserId(userId: stick.userId!)
                        stamp.setGood(good: stick.good!)
                        
                        if let stampData = stick.staticData{
                            print("stampname:\(String(describing: stampData.stampName))")
                            
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
                                        DispatchQueue.global().async {
                                            DispatchQueue.main.async {
                                                self.leftCollectionView.reloadData()
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
                        let requestBody: [String: Any?] = ["userId": stick.userId!, "currentUserId": self.currentUser?.objectId]
                        
                        // スクリプトを実行
                        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                            switch result{
                            case let .success(data):
                                print("pullYourInformScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                                
                                do{
                                    let decoder = JSONDecoder()
                                    
                                    let json = try decoder.decode(UserAllData.self, from: data!)
                                    
                                    // フォロー情報をセット
                                    user.setFollow(bool: json.follow!)
                                    if let userInfo = json.result{
                                        if let userData = userInfo.userData{
                                            // ユーザー名をセット
                                            user.setUserName(userName: userData.userName!)
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
                                                    user.setUserIconImage(userIconImage: image)
                                                }
                                                
                                                // コレクションビューを更新
                                                print("コレクションビューを更新")
                                                DispatchQueue.global().async{
                                                    DispatchQueue.main.async {
                                                        self.leftCollectionView.reloadData()
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
                                                self.leftCollectionView.reloadData()
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
                        
                        // スタンプリストに追加
                        self.stamps.append((stamp, user))
                        
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
    
    @objc func onGoodButton(_ sender: UIButton){
        // TODO: スタンプかスタンプアートかを確認しないといけない(tagに見分ける情報を付与するか？)
        print("タップされたセルのButtonのtag:\(sender.tag)")
        
        // TODO:すでにグッドされているか判定→されていなかったらグッドするよ処理をする
        // TODO:されていたらグッドやめるよ処理をする
        
        
    }
    
    // MARK: Action
    @IBAction func searchButtonAction(_ sender: Any) {
        if searchTextField.text == ""{
            print("検索文字列が入力されてないよ")
        }else{
            print("検索するよ:\(String(describing: searchTextField.text))")
            searchWord = searchTextField.text
            stampSkip = 0
            stampArtSkip = 0
            pullSearchStampStick()
            pullSearchStampArtStick()
        }
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
            cell.goodButton.tag = indexPath.row
            print("left:\(indexPath.row)")
            
            // セルに情報を付加
            cell.userName.text = stamps[indexPath.row].1.getUserName()
            if let userIcon = self.stamps[indexPath.row].1.getUserIconImage(){
                cell.userIconImageView.image = userIcon
            }
            if let stampImage = self.stamps[indexPath.row].0.stampImage{
                cell.stickImageView.image = stampImage
            }
            cell.numberOfGood.text = String(self.stamps[indexPath.row].0.good!)
            
        }else{
            // StampArtのセル
            cell.goodButton.tag = indexPath.row
            print("right:\(indexPath.row)")
            
            cell.userName.text = "right"
        }
        
        // goodButtonにアクションを追加
        cell.goodButton.addTarget(self, action:  #selector(self.onGoodButton(_:)), for: .touchUpInside)
        
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
    
    
    
}
