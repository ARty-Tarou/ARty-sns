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
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var selfIntroduction: UILabel!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var myStickCollectionView: UICollectionView!
    
    // カレントユーザー
    let user = NCMBUser.currentUser
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        //　TODO: スクリプトでユーザーの詳細情報を取得する
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
                    
                    let json = try decoder.decode([UserData].self, from: data!)
                    
                    print(json.count)
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("pullMyInformScript実行に失敗:\(error)")
            }
        })
        
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
        
        // UserProductを表示する
        userStick()
    }
    
    // MARK: JSON
    struct UserData: Codable{
        // userIcon
        let iconImageName: String?
        // selfIntroduction
        let selfIntroduction: String?
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
    
    // MARK: Methods
    
    func userStick(){
        // スクリプトでstickリストを取得
        let script = NCMBScript(name: "pullMyStick.js", method: .post)
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": self.user?.objectId]
        
        // スクリプト実行 JSON形式でユーザーのStickリストを取得
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
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
                                        }
                                        
                                        // コレクションビューを更新
                                        print("コレクションビューを更新")
                                        DispatchQueue.global().async {
                                            DispatchQueue.main.async {
                                                self.myStickCollectionView.reloadData()
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
                                    self.myStickCollectionView.reloadData()
                                }
                            }
                        }else{
                            // スタンプアートの場合(スタンプアートリストに入れていく。)
                        }
                    }
                }catch{
                    print("error")
                }
                
            case let .failure(error):
                print("upllMyStickScript実行に失敗:\(error)")
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if stampTab.isEnabled == false{
            // スタンプの場合
            print(stamps[indexPath.row].stampName!)
        }else{
            // スタンプアートの場合
            
        }
    }
    
    // MARK: Actions
    
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

 }
