import UIKit
import NCMB

class StickLogic{
    
    func saveFile(data: Data?, detail: String){
        
        print("data:\(String(describing: data))")
        // 画像をファイルストアに保存
        // カレントユーザーを取得
        guard let user = NCMBUser.currentUser else{
            fatalError("カレントユーザー取得失敗")
        }
        
        // 日付を取得
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
        print("date:\(dateFormatter.string(from: date))")
        
        // ファイル名を設定
        let fileName = "\(user.objectId!).\(dateFormatter.string(from: date))"
        print("fileName:\(fileName)")
        
        // ファイルストアに保存
        let file: NCMBFile = NCMBFile(fileName: fileName)
        file.saveInBackground(data: data!, callback: {result in
            switch result{
            case .success:
                print("保存に成功")
                
                // スクリプトインスタンスを生成
                let script = NCMBScript(name: "saveStick.js", method: .post)
                
                // ボディ設定
                let requestBody: [String: Any?] = ["userId": user.objectId, "detail": detail, "stampName": fileName, "flag": 0]
                
                // スクリプト実行
                script.executeInBackground(headers: [:], queries: [:], body: requestBody, callback: {result in
                    switch result{
                    case let .success(data):
                        print("result:\(result)")
                        print("script実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "" )")
                    case let .failure(error):
                        print("script実行に失敗:\(error)")
                    }
                })
            case let .failure(error):
                print("保存に失敗:\(error)")
                return;
            }
        })
    }
}
