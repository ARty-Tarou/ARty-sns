//
//  TimelineViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/27.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    // スタンプリスト
    var stamps: [(Stamp)] = []
    
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
        
        // TODO: スタンプリスト作成
        let stamp1 = Stamp(name: "a", image: UIImage(named: "urety"))
        stamps.append(stamp1!)
        let stamp2 = Stamp(name: "b", image: UIImage(named: "kanaty"))
        stamps.append(stamp2!)
        let stamp3 = Stamp(name: "c", image: UIImage(named: "muty"))
        stamps.append(stamp3!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        
        cell.userNameLabel.text = self.stamps[indexPath.row].name
        cell.goodNum.text = String(indexPath.row)
        
        
        return cell
    }
    
    // セル数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return stamps.count
    }
}
