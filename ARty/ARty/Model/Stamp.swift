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
    var stampName: String
    var stampImage: UIImage?
    var userId: String?
    var userName: String?
    var good: Int?

    // MARK: Initialization
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
    func setStampImage(stampImage: UIImage?){
        self.stampImage = stampImage
    }
    
    func setUserName(userName: String){
        self.userName = userName
    }
}
