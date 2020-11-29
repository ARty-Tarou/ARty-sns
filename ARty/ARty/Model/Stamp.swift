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
    private var objectId: String?
    private var fileName: String?
    private var stampImage: UIImage?
    private var userId: String?
    private var detail: String?
    private var numberOfGood: Int?
    private var good: Bool?
    private var numberOfViews: Int?
    
    // スタンプ(true)か、ar(false)か
    private var type: Bool?
    

    // MARK: Initialization
    init(){}
    
    init(name: String, image: UIImage?) {
        self.fileName = name
        self.stampImage = image
    }
    
    init(fileName: String,stampImage: UIImage,  userId: String,detail: String, numberOfGood: Int, numberOfViews: Int) {
        self.fileName = fileName
        self.stampImage = stampImage
        self.userId = userId
        self.detail = detail
        self.numberOfGood = numberOfGood
        self.numberOfViews = numberOfViews
    }
    
    // MARK: Setter & Getter
    func setObjectId(objectId: String){
        self.objectId = objectId
    }
    
    func getObjectId() -> String?{
        return objectId
    }
    
    func setFileName(fileName: String){
        self.fileName = fileName
    }
    
    func getFileName() -> String?{
        return fileName
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
    
    func setType(type: Bool) {
        self.type = type
    }
    
    func getType() -> Bool? {
        return type
    }
}
