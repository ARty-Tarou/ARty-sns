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
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    @IBOutlet weak var leftCollectionView: UICollectionView!
    @IBOutlet weak var rightCollectionView: UICollectionView!
    
    
    
    
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
    
    
    
    
    // MARK: Method
    
    // 検索する文字列
    var searchWord: String? = nil
    func pullSearchStampStick(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearchStampStick.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?]  = ["searchWord": searchWord]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchStampScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                
            case let .failure(error):
                print("pullSearchStampScript実行に失敗:\(error)")
            }
        })
    }
    
    func pullSearchStampArtStick(){
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pullSearchStampArtStick.js", method: .post)
        // ボディを設定
        let requestBody: [String: Any?] = ["searchWord": searchWord]
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("pullSearchStampArtStickScript実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                
                
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
            print("検索するよ:\(String(describing: searchTextField.text))")
            searchWord = searchTextField.text
            pullSearchStampStick()
            pullSearchStampArtStick()
        }
    }
    
    
    // MARK: UITextField
    
    // テキストフィールドでリターンが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        // デバッグ用出力
        if let str = searchTextField.text{
            print("検索：\(str)")
        }
        // MARK: リクエスト処理
        // TODO: 検索処理のスクリプトを記述していく。と思ったけど検索ボタンおしたらに変えた。

        
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
            
            cell.userName.text = "left"
        }else{
            // StampArtのセル
            cell.goodButton.tag = indexPath.row
            print("right:\(indexPath.row)")
            
            cell.userName.text = "right"
        }
        
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == leftCollectionView{
            // Stampのセル
            return 5
        }else{
            // Stampのセル
            return 10
        }
    }
    
    // セルが選択されたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    

}
