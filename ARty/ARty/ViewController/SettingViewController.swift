//
//  SettingViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate{
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: Properties
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var stampTab: UIButton!
    @IBOutlet weak var artsTab: UIButton!
    @IBOutlet weak var userProductTableView: UITableView!
    
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
        
        //
        // スクリプトインスタンス生成
        let script = NCMBScript(name: "pullMyInform.js", method: .post)
        
        // ボディ設定
        let requestBody:[String: Any?] = ["userId": self.user?.objectId]
        
        // スクリプト実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullMyInformScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            case let .failure(error):
                print("pullMyInformScript実行に失敗:\(error)")
            }
        })
        
        // Table Viewの設定
        userProductTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        userProductTableView.delegate = self
        userProductTableView.dataSource = self
        
        // Stampタブを選択状態にする
        stampTab.isEnabled = false
        
        // UserProductを表示する
        userProduct()
    }
    
    // MARK: JSON
    struct StampJson: Codable{
        // stickのobjectId
        let objectId: String?
        // stampName
        let stampName: String?
        // userName
        let userName: String?
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
        let staticData : StaticData?
    }
    
    struct StaticData: Codable{
        // スタンプ名
        let stampName: String?
        // スタンプアート名
        let stampArtName: String?
    }
    
    struct StampImageJson: Codable{
        let stampData: Data?
    }
    
    // MARK: Methods
    
    // UserProduct
    func userProduct(){
        if stampTab.isEnabled == false{
            // スタンプリストを表示する処理
            print("stampListを表示する")
            
            // TODO: テスト
            // スタンプリストを初期化
            stamps = []
            
            // ファイルストアからスタンプリストを取得
            // スクリプトインスタンスを生成
            let script = NCMBScript(name: "pullMyStick.js", method: .post)
            
            // ボディ設定
            let requestBody: [String: Any?] = ["userId": self.user?.objectId]
            
            // スクリプト実行 JSON形式で自分が投稿したスタンプリストを取得
            script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                switch result{
                case let .success(data):
                    print("pullMyStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                    
                    do{
                        
                        
                        let decoder = JSONDecoder()
                        
                        let json = try decoder.decode([StickData].self, from: data!)
                        
                        // 取得したjsonのデータ数だけ回す
                        for stick in json{
                            // スタンプの場合回す
                            if stick.stamp == true{
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
                                            print("画像取得に成功")
                                            // データを画像に変換
                                            if let image = data.flatMap(UIImage.init){
                                                // スタンプに画像をセット
                                                print("画像をセット:\(stampData.stampName!)")
                                                stamp.setStampImage(stampImage: image)
                                                
                                                // テーブルビューを更新
                                                print("テーブルビューを更新")
                                                DispatchQueue.global().async{
                                                    DispatchQueue.main.async{
                                                        self.userProductTableView.reloadData()
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
                                // テーブルビューを更新
                                print("テーブルビューを更新します。")
                                DispatchQueue.global().async{
                                    DispatchQueue.main.async{
                                        self.userProductTableView.reloadData()
                                    }
                                }
                                
                            }
                            
                            // TODO: スクリプトで画像を取得
                            // スクリプトインスタンス生成
                            /*let script = NCMBScript(name: "pullMyFile.js", method: .post)
                            
                            // ボディ設定
                            let requestBody: [String: Any?] = ["fileName": item.stampName]
                            
                            // スクリプト実行
                            script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                                switch result{
                                case let .success(data):
                                    
                                    let decoder = JSONDecoder()
                                    
                                    do{
                                        let json = try decoder.decode(StampImageJson.self, from: data!)
                                        
                                        guard let image = UIImage(data: json.stampData!) else{
                                            fatalError("画像変換失敗")
                                        }
                                        /*guard let image = json.stampData.flatMap(UIImage.init) else{
                                            fatalError("画像に変換失敗")
                                        }*/
                                        let stamp: Stamp! = Stamp(name: item.userName!, image: image)
                                        
                                        self.stamps.append(stamp)
                                    }catch{
                                        print("StampImageJson取り出し失敗")
                                    }
                                    
                                    
                                case let .failure(error):
                                    print("error:\(error)")
                                }
                            })*/
                            /*
                            let stamp: Stamp! = Stamp(name: item.stampName!, image: UIImage(named: "urety"))
                            self.stamps.append(stamp)*/
                        }
                        
                        // テーブルビューを更新
                        /*print("テーブルビューを更新します。")
                        DispatchQueue.global().async{
                            DispatchQueue.main.async{
                                self.userProductTableView.reloadData()
                            }
                        }*/
                        
                    }catch{
                        print("error")
                    }
                    
                    
                case let .failure(error):
                    print("pullMyStickScript実行に失敗:\(error)")
                }
            })
        }else{
            // アートリストを表示する処理
            print("artListを表示する")
            stamps = []
            // テーブルViewを更新
            self.userProductTableView.reloadData()
        }
    }
    
    // MARK: TableView
    // セルの総数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // スタンプリストの総数
        return stamps.count
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    // セルに値を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        
        cell.userNameLabel.text = stamps[indexPath.row].userId
        if let image = stamps[indexPath.row].stampImage{
            cell.productImageView.image = image
        }
        
        return cell
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
        
        // テーブルViewを更新
        userProduct()
    }
    
    @IBAction func artsTabButtonAction(_ sender: Any) {
        print("アートタブが押されたよ")
        // スタンプタブを未選択状態、アートタブを選択状態にする
        stampTab.isEnabled = true
        artsTab.isEnabled = false
        
        // テーブルViewを更新
        userProduct()
    }

 }
