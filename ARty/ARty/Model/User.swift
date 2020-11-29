//
//  User.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//
import UIKit

class User{
    // MARK: Properties
    private var userId: String?
    private var userName: String?
    private var userIconImage: UIImage?
    private var selfIntroduction: String?
    private var numberOfFollowed: Int?
    private var numberOfFollow: Int?
    private var mailAddress: String?
    private var password: String?
    
    // カレントユーザーにフォローされているか
    private var fallow: Bool?
    
    // MARK: Initialization
    init(){}
    
    init(userId: String?, userName: String?, userIconImage: UIImage?){
        self.userId = userId
        self.userName = userName
        if let image = userIconImage{
            self.userIconImage = image
        }
    }
    
    init(mailAddress: String?, password: String?){
        self.mailAddress = mailAddress
        self.password = password
    }
    
    // MARK: Getter & Setter
    func getUserId() -> String?{
        return userId
    }
    
    func setUserId(userId: String){
        self.userId = userId
    }
    
    func getUserName() -> String?{
        return userName
    }
    
    func setUserName(userName: String){
        self.userName = userName
    }
    
    func getUserIconImage() -> UIImage?{
        return userIconImage
    }
    
    func setUserIconImage(userIconImage: UIImage){
        self.userIconImage = userIconImage
    }
    
    func getSelfIntroduction() -> String?{
        return selfIntroduction
    }
    
    func setSelfIntroduction(selfIntroduction: String){
        self.selfIntroduction = selfIntroduction
    }
    
    func getNumberOfFollowed() -> Int?{
        return numberOfFollowed
    }
    
    func setNumberOfFollowed(numberOfFollowed: Int){
        self.numberOfFollowed = numberOfFollowed
    }
    
    func getNumberOfFollow() -> Int?{
        return numberOfFollow
    }
    
    func setNumberOfFollow(numberOfFollow: Int){
        self.numberOfFollow = numberOfFollow
    }
    
    func getMailAddress() -> String?{
        return mailAddress
    }
    
    func setMailAddress(mailAddress: String){
        self.mailAddress = mailAddress
    }
    
    func getPassword() -> String?{
        return password
    }
    
    func setFollow(bool: Bool){
        self.fallow = bool
    }
    
    func getFollow() -> Bool?{
        return self.fallow
    }
}
