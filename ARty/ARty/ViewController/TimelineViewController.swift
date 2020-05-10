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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Cellに使われるクラスを登録
        collectionView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellWithReuseIdentifier: "timelineCell")
        
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
    struct TimelineData: Codable{
        // スタンプ名
        let stampName: String?
        // このスタンプのgood数
        let good: Int?
        // スタンプの作成者のuserId
        let userId: String?
        
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
                    
                    let json = try decoder.decode([TimelineData].self, from: data!)
                    
                    // 取得したjsonのデータ数だけ回す
                    for item in json{
                        print("stampName:\(String(describing: item.stampName))")
                        
                        // スタンプインスタンスを生成
                        let stamp: Stamp = Stamp(name: item.stampName!, userId: item.userId!, good: item.good!)
                        
                        // ファイルストアから画像を取得
                        // ファイルの指定
                        let file = NCMBFile(fileName: item.stampName!)
                        
                        // ファイルの取得
                        print("画像を取ってきます。")
                        
                        file.fetchInBackground(callback: {result in
                            switch result{
                            case let .success(data):
                                
                                // データを画像に変換
                                if let image = data.flatMap(UIImage.init){
                                    // スタンプに画像をセット
                                    print("画像をセット")
                                    stamp.setStampImage(stampImage: image)
                                }
                                
                            case let .failure(error):
                                print("ファイル取得失敗:\(error)")
                            }
                        })
                        
                        // ユーザー情報の取得処理
                        
                        
                        // タイムラインリストに追加
                        //let stamp: Stamp! = Stamp(name: item.stampName!, userId: item.userId!, good: item.good!)
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
    
    // MARK: UICollectionViewDataSource
    
    // セルを返す
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timelineCell", for: indexPath) as! TimelineCell
        
        cell.userNameLabel.text = self.timelineList[indexPath.row].userId
        if let image = self.timelineList[indexPath.row].stampImage{
            cell.stampImageView.image = image
        }
        cell.goodNum.text = String(self.timelineList[indexPath.row].good!)
        
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timelineList.count
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        // indexPath.rowから選択されたセルを取得
        print(timelineList[indexPath.row].stampName)
        
        
    }
}
