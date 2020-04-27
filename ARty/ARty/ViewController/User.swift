//
//  User.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import Foundation

struct User{
    private let mailAddress: String
    private let password: String
    
    init(mailAddress: String, password: String){
        self.mailAddress = mailAddress
        self.password = password
    }
    
    func getMailAddress() -> String{
        return mailAddress
    }
    
    func getPassword() -> String{
        return password
    }
    
}
