//
//  User.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//
class User{
    // MARK: Properties
    private var userId: String?
    private var userName: String?
    private var mailAddress: String?
    private var password: String?
    
    // MARK: Initialization
    
    init(mailAddress: String, password: String){
        self.mailAddress = mailAddress
        self.password = password
    }
    
    func getMailAddress() -> String?{
        return mailAddress
    }
    
    func getPassword() -> String?{
        return password
    }
    
}
