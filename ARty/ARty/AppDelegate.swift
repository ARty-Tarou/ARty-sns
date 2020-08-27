//
//  AppDelegate.swift
//  ARty
//
//  Created by 今吉佑介 on 2020/04/15.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import ARKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //********** APIキーの設定 **********
    let applicationkey = "a8b68d30b39077b903e6eb7f9496b55bc134b5b6718140d1bb3b0e1a323ec4a7"
    let clientkey      = "437b274dfbd4347193a3e2e33828ca475c77e734288f2cd793da1397394b0fd6"
    
    // カレントユーザー
    var currentUser: User? = User()
    
    // Graffiti
    var fontSize:Float = 0.003
    var lineColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    // Stamp
    var stampHeight: Int = 500
    var stampWidth = 500
    var stampImage = UIImage(named: "stick")
    
    // 識別用
    var stampImageIndex = 0 // 選択中のスタンプ
    var stampImageUsed = false // 選択中のスタンプが一度でも使用されたか
    var setStampData: [SetStampData] = [] // 設置されたスタンプのデータ
    var stampImageData: [StampImageData] = [] // スタンプ画像のデータ
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // APIキーの設定とSDK初期化
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey);
        return true
        
    }
    
    // MARK: Method
    
    func setStampInit() {
        print("do init")
        self.stampImageIndex = 0
        self.stampImageUsed = false
        self.setStampData = []
        self.stampImageData = []
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }


}

