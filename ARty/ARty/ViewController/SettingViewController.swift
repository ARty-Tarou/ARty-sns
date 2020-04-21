//
//  SettingViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import NCMB

class SettingViewController: UIViewController{

    // MARK: Properties
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // カレントユーザーの情報を取得
        if let user = NCMBUser.currentUser{
            // userの名前を取得
            if let name = user.userName{
                userName.text = name
            }
            
            // ファイルストアに画像があるか検索            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = NCMBUser.currentUser{
            // userの名前を取得
            if let name = user.userName{
                userName.text = name
            }
        }
    }
    
    // MARK: Actions
    
    // changeボタンをタップしたとき
    
    @IBAction func changeButtonAction(_ sender: Any) {
        // 画面遷移
        performSegue(withIdentifier: "change", sender: nil)
        
    }

    // 画面更新
    func updateView(){
        
    }
    
    
    /*
    @IBAction func iconChangeButtonAction(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        //フォトライブラリから読み込み
        imagePickerController.sourceType = .photoLibrary
        
        //モーダルを開く
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
 */
    
    // MARK: Delegate method
    /*
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // モーダルのViewControllerを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    //画像を選択した後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
          fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //選択した画像をスタンプ画像に反映
        iconImage.image = selectedImage
        
        //Pickerを閉じる
        dismiss(animated: true, completion: nil)
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

 }
