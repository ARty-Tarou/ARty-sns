//
//  ImageViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/09/11.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class ImageViewController: UIViewController {
    
    // MARK: Properties
    // 表示する画像
    var image: UIImage? = nil
    var stampName: String? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Labelの設定
        infoLabel.isHidden = true
        
        // imageを取得できているか
        if image == nil {
            // 取得していなかった場合
            
            downloadButton.isEnabled = false
            
            // ファイルストアから画像を取得
            pullImage()
        } else {
            imageView.image = self.image
            downloadButton.isEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Method
    func pullImage() {
        // ファイル名を取得
        let fileName = self.stampName
        
        // ファイルストアからファイルを取得
        let file = NCMBFile(fileName: fileName!)
        
        file.fetchInBackground(callback: {result in
            switch result {
            case let .success(data):
                print("画像取得に成功")
                
                // データをUIImageに変換
                let image = data.flatMap(UIImage.init)
                
                // ビューに表示
                self.imageView.image = image
                
                // ダウンロードボタンを使用可能にする
                self.downloadButton.isEnabled = true
                
            case let .failure(error):
                print("画像取得に失敗:\(error)")
                self.infoLabel.isHidden = false
            }
        })
    }
    
    // MARK: Action
    @IBAction func downloadButtonAction(_ sender: Any) {
        // イメージを取得
        let image = self.imageView.image!
        print("image:\(image)")
        
        // アラート
        let alertController = UIAlertController(title: "保存", message: "画像を保存しますか？", preferredStyle: .alert)
        
        // ボタンを作成
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            // 画像を保存
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        
        // アクションを追加
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        // ダイアログを表示
        present(alertController, animated: true, completion: nil)
    }
}
