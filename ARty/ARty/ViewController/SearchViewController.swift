//
//  SearchViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/22.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // TableViewの設定
        leftTableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        rightTableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        leftTableView.delegate = self
        rightTableView.delegate = self
        leftTableView.dataSource = self
        rightTableView.dataSource = self
        
        // デリゲートを設定
        searchTextField.delegate = self
    }
    
    
    // MARK: Delegate methods
    
    // テキストフィールドでリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // デバッグ用出力
        if let str = searchTextField.text{
            print("検索：\(str)")
        }
        // MARK: リクエスト処理
        
        // TODO: 検索処理のスクリプトを記述していく。
        // Scriptインスタンスを生成
        
        
        // TODO: ニフクラにアクセスして検索する処理を書いていく
        
        /*
        // リクエストURL
        guard let requestURL = URL(string: "https://...")
        
        // リクエストに必要な情報を生成
        let req = URLRequest(url: requestURL)
        // データ転送を管理するためのセッション生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = session.detaTask(with: req, completionHandler: {(data, response, error) in
            // セッション終了
            session.finishTasksAndInvalidate()
            // do try catch エラーハンドリング
            do{
                // JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                // 受け取ったJSONデータをパース（解析）して格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                print(json)
            }catch{
                // エラー処理
                print("エラー")
            }
        })
        // ダウンロード開始
        task.resume()
 */
        
        return true
    }
    
    // セルの総数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // スタンプリストの総数
        
        if tableView == leftTableView{
            return 5 //leftTableViewのセルの数
        }else{
            return 10 //rightTableViewのセルの数
        }
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    // セルに値を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
        
        if tableView == leftTableView{
            cell.SearchUserName.text = "left"
            cell.SearchUserImage.image = UIImage(named: "FirstIcon")
            cell.SearchImage.image = UIImage(named: "urety")
            cell.SearchDescribe.text = "概要"
        }else{
            cell.SearchUserName.text = "right"
            cell.SearchUserImage.image = UIImage(named: "FirstIcon")
            cell.SearchImage.image = UIImage(named: "muty")
            cell.SearchDescribe.text = "概要"
        }
        
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
