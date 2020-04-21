//
//  LogoutLogic.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/21.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import Foundation
import NCMB

class LogoutLogic{
    
    func logout(){
        NCMBUser.logOutInBackground(callback: {result in
            switch result{
                case .success:
                // ログアウトに成功した場合の処理
                print("ログアウトに成功")
                
                // ログイン状況の確認
                if let user = NCMBUser.currentUser{
                    print("ログイン中のユーザー: \(user.userName!)")
                }else{
                    print("ログインしてないです")
                }
            case let .failure(error):
                // ログアウトに失敗した場合の処理
                print("ログアウトに失敗しました: \(error)")
            }
        })
    }

}
