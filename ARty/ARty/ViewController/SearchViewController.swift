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
    
    // MARK: Codable
    
    
    // MARK: Method
    func pullSearch(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearch.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?]  = ["userId": NCMBUser.currentUser?.objectId, "word": searchTextField.text]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                
            case let .failure(error):
                print("pullSearchScript実行に失敗:\(error)")
            }
        })
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

}
