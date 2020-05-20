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
    private var stampName: String?
    private var stampImage: UIImage?
    private var userId: String?
    private var detail: String?
    private var numberOfGood: Int?
    private var good: Bool?
    private var numberOfViews: Int?
    

    // MARK: Initialization
    init(){}
    
    init(name: String, image: UIImage?) {
        self.stampName = name
        self.stampImage = image
    }
    
    init(stampName: String,stampImage: UIImage,  userId: String,detail: String, numberOfGood: Int, numberOfViews: Int) {
        self.stampName = stampName
        self.stampImage = stampImage
        self.userId = userId
        self.detail = detail
        self.numberOfGood = numberOfGood
        self.numberOfViews = numberOfViews
    }
    
    // MARK: Setter & Getter
    func setStampName(stampName: String){
        self.stampName = stampName
    }
    
    func getStampName() -> String?{
        return stampName
    }
    
    func setStampImage(stampImage: UIImage?){
        self.stampImage = stampImage
    }
    
    func getStampImage() -> UIImage?{
        return stampImage
    }
    
    func setUserId(userId: String){
        self.userId = userId
    }
    
    func getUserId() -> String?{
        return userId
    }
    
    func setDetail(detail: String){
        self.detail = detail
    }
    
    func getDetail() -> String?{
        return detail
    }
    
    func setNumberOfGood(numberOfGood: Int){
        self.numberOfGood = numberOfGood
    }
    
    func getNumberOfGood() -> Int?{
        return numberOfGood
    }
    
    func setGood(good: Bool){
        self.good = good
    }
    
    func getGood() -> Bool?{
        return good
    }
    
    func setNumberOfViews(numberOfViews: Int){
        self.numberOfViews = numberOfViews
    }
    
    func getNumberOfViews() -> Int?{
        return numberOfViews
    }
}
