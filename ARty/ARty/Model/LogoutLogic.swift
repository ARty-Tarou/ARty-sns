//
//  LogoutLogic.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/21.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//
import NCMB

class LogoutLogic{
    
    func logout() -> Bool{
        switch NCMBUser.logOut(){
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
