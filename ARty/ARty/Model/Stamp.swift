//
//  Stamp.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/22.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class Stamp {

    // MARK: Properties
    var stampName: String?
    var stampImage: UIImage?
    var userId: String?
    var userName: String?
    var userIcon: UIImage?
    var good: Int?

    // MARK: Initialization
    init(){}
    
    init(name: String){
        self.stampName = name
    }
    
    init?(name: String, image: UIImage?) {
    
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // Initialize stored properties
        self.stampName = name
        self.stampImage = image
    }
    
    init(name: String,  userId: String, good: Int) {
        self.stampName = name
        self.userId = userId
        self.good = good
    }
    
    // MARK: Setter
    func setStampName(stampName: String){
        self.stampName = stampName
    }
    
    func setStampImage(stampImage: UIImage?){
        self.stampImage = stampImage
    }
    
    func setUserId(userId: String){
        self.userId = userId
    }
    
    func setUserName(userName: String){
        self.userName = userName
    }
    
    func setUserIcon(userIcon: UIImage?){
        self.userIcon = userIcon
    }
    
    func setGood(good: Int){
        self.good = good
    }
}
