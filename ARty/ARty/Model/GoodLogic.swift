//
//  GoodLogic.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/05/21.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//
import NCMB

class GoodLogic{
    
    
    let currentUser = NCMBUser.currentUser
    
    func pushGood(objectId: String){
        print("goodするよ:\(objectId)")
        
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "pushMyGood.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["stickId": objectId, "userId": currentUser?.objectId]
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case .success:
                print("pushMyGoodScript実行に成功")
            case let .failure(error):
                print("pushMyGoodScript実行に失敗:\(error)")
            }
        })
    }
    
    func undoGood(objectId: String){
        print("good解除するよ:\(objectId)")
        
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "undoGood.js", method: .post)
        
        // ボディを設定
        let requestBody: [String: Any?] = ["stickId": objectId, "userId": currentUser?.objectId]
        
        // スクリプトを実行
        script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
            switch result{
            case .success:
                print("undoGoodScript実行に成功")
            case let .failure(error):
                print("undoGoodScript実行に失敗:\(error)")
            }
        })
    }
    
}
