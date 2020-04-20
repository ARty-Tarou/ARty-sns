//
//  User.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/19.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import Foundation

struct User{
    private let email: String
    private let password: String
    
    init(email: String, password: String){
        self.email = email
        self.password = password
    }
    
    func getEmail() -> String{
        return email
    }
    
    func getPassword() -> String{
        return password
    }
    
}
