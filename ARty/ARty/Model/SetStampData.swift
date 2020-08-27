//
//  SetStampData.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/08/25.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class SetStampData {
    
    // MARK: Properties
    private var anchorName: String?
    private var stampNumber: Int?
    private var size: (height: Int?, width: Int?)
    
    // MARK: Method
    init(anchorName: String, stampNumber: Int?, height: Int, width: Int) {
        self.stampNumber = stampNumber
        self.size.height = height
        self.size.width = width
    }
    
    // MARK: Getter
    func getAnchorName() -> String? {
        return self.anchorName
    }
    
    func getStampNumber() -> Int? {
        return self.stampNumber
    }
    
    func getSize() -> (Int?, Int?) {
        return (self.size.height, self.size.width)
    }
}
