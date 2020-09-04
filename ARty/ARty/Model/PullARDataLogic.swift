//
//  PullARDataLogic.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/09/02.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import Foundation
import UIKit
import NCMB

class PullARDataLogic {
    
    // MARK: Codable
    struct PullArDataResult: Codable {
        // setStampData
        let setStampData: [PullSetStampData]
        // stampImageData
        let stampImageData: [PullStampImageData]
    }
    
    struct PullSetStampData: Codable {
        // anchorName
        let anchorName: String
        // stampNumber
        let stampNumber: Int
        // height
        let height: Int
        // width
        let width: Int
    }
    
    struct PullStampImageData: Codable {
        // stampImageName
        let stampImageName: String
        // stampImageNumber
        let stampImageNumber: Int
    }
    
    func pullARData(worldMapName: String) {
        // stampImageData, setStampDataを取得
        let script = NCMBScript(name: "pullArData.js", method: .post)
        let requestBody: [String: Any?] = ["worldMap": worldMapName]
        let result = script.execute(headers: [:], queries: [:], body: requestBody)
        
        switch result {
        case let .success(data):
            print("pullArData実行成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            
            do {
                let decoder = JSONDecoder()
                
                let json = try decoder.decode(PullArDataResult.self, from: data!)
                
                // 配列を作成
                
                var setStampData: [SetStampData] = []
                var stampImageData: [StampImageData] = []
                
                for pullSetStampData in json.setStampData {
                    let anchorName = pullSetStampData.anchorName
                    let stampNumber = pullSetStampData.stampNumber
                    let height = pullSetStampData.height
                    let width = pullSetStampData.width
                    
                    let resultSetStampData = SetStampData(anchorName: anchorName, stampNumber: stampNumber, height: height, width: width)
                    setStampData.append(resultSetStampData)
                }
                
                for pullStampImageData in json.stampImageData {
                    let stampImageName = pullStampImageData.stampImageName
                    let stampImageNumber = pullStampImageData.stampImageNumber
                    var stampImage = UIImage(named: "firstIcon")
                    
                    // ファイルストアから画像を取得
                    let file = NCMBFile(fileName: stampImageName)
                    let result = file.fetch()
                    
                    switch result {
                    case let .success(data):
                        print("\(file.fileName)取得成功")
                        
                        stampImage = data.flatMap(UIImage.init)
                    case let .failure(error):
                        print("\(file.fileName)取得失敗\(error)")
                    }
                    let resultStampImageData = StampImageData(stampImage: stampImage!, stampImageName: stampImageName, stampNumber: stampImageNumber)
                    stampImageData.append(resultStampImageData)
                }
                
                // AppDelegateに格納
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                // TODO: appdelegate
                appDelegate.pullSetStampData = setStampData
                appDelegate.pullStampImageData = stampImageData
                
                
            } catch {
                print("error")
            }
        case let .failure(error):
            print("pullArData実行失敗:\(error)")
        }
        
    }
}
