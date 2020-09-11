//
//  HelppageViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/05/14.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class HelppageViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var helpTable: UITableView!
    
    var chosenCell: Int!
    
    let labelTitles: [String] = [
        "初めに","ARtyの使い方","カメラ機能の使い方",
        "goodの活用方法","投稿の方法","その他"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableViewの設定
        helpTable.delegate = self
        helpTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //セルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelTitles.count
    }
    
    //各セルの要素を設定
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //tableCellのIDでUITableCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)
        
        cell.textLabel?.text = labelTitles[indexPath.row]
        
        return cell
    }

    //cellが選択された時
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        
        
        //選択したセルの保存
        chosenCell = indexPath.row
        
        //セルの選択を解除
        tableView.deselectRow(at: indexPath,animated: true)
        
        //別画面に遷移しますよ
        if chosenCell != nil{
            performSegue(withIdentifier: "toSubHelpViewController", sender: nil)
        }
    }
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 遷移先のViecControllerのインスタンスを生成
        let secVC: SubHelpViewController = (segue.destination as? SubHelpViewController)!
        // SubHelpViewControllerのgetCellに選択されたテキストを設定する
        secVC.getCell = chosenCell
        
    }
}


