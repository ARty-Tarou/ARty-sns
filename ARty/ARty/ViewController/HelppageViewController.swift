//
//  HelppageViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/05/14.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class HelppageViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var Helptable: UITableView!
    
    var chosenCell: Int!
    
    let labelTitles: NSArray = [
        "初めに","ARtyの使い方","カメラ機能の使い方",
        "goodの活用方法","投稿の方法","その他"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //セルの数を指定
    func tableView(_ Helptable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelTitles.count
    }
    
    //各セルの要素を設定
    func tableView(_ Helptable: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //tableCellのIDでUITableCellのインスタンスを作成
        let cell = Helptable.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)
        //Tag番号１でUILabelインスタンスの生成
        let label = cell.viewWithTag(1)as! UILabel
        label.text = String(describing:labelTitles[indexPath.row])
        
        return cell
    }
    //セルのサイズ
    func tableView(_ Helptable: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0
    }
    //仮だけど戻るボタンの生成もしときます
    @IBAction func backtoMypage(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    //cellが選択された時
    func tableView(_ Helptable:UITableView,didSelectRowAt indexPath:IndexPath){
        
        
        //選択したセルの保存
        chosenCell = indexPath.row
        
        //セルの選択を会場
        Helptable.deselectRow(at: indexPath,animated: true)
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


