//
//  StampImage.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/08/25.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class StampImageData {
    
    // MARK: Properties
    private var stampImage: UIImage?
    private var stampImageName: String?
    private var stampNumber: Int?
    
    // MARK: Method
    init(stampImage: UIImage, stampImageName: String, stampNumber: Int) {
        self.stampImage = stampImage
        self.stampImageName = stampImageName
        self.stampNumber = stampNumber
    }
    
    
    // MARK: Getter
    func getStampImage() -> UIImage? {
        return self.stampImage
    }
    
    func getStampImageName() -> String? {
        return self.stampImageName
    }
    
    func getStampNumber() -> Int? {
        return self.stampNumber
    }
}
