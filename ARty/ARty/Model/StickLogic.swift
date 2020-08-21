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
        
        // ファイル名を設定
        let fileName = getFileName(objectId: user.objectId!)
        
        // ファイルストアに保存
        let file: NCMBFile = NCMBFile(fileName: "s.\(fileName)")
        file.saveInBackground(data: data!, callback: {result in
            switch result{
            case .success:
                print("保存に成功")
                
                // スクリプトインスタンスを生成
                let script = NCMBScript(name: "saveStick.js", method: .post)
                
                // ボディ設定
                let requestBody: [String: Any?] = ["userId": user.objectId, "detail": detail, "fileName": fileName, "flag": 0]
                
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
    
    func saveFile(data: Data?, arData: Data?, detail: String) {
        print("data:\(String(describing: data))")
        // 画像、arをファイルストアに保存
        
        // カレントユーザーを取得
        guard let user = NCMBUser.currentUser else{
            fatalError("カレントユーザー取得失敗")
        }
        
        let fileName = getFileName(objectId: user.objectId!)
        
        // ファイルストアに保存 画像
        let imageFile: NCMBFile = NCMBFile(fileName: "i.\(fileName)")
        
        imageFile.saveInBackground(data: data!, callback: {result in
            switch result {
            case .success:
                print("imageFile保存に成功")
            case let .failure(error):
                print("imageFile:\(error)")
            }
        })
        
        // ファイルストアに保存 arデータ
        let arFile: NCMBFile = NCMBFile(fileName: "a.\(fileName)")
        
        arFile.saveInBackground(data: arData!, callback: {result in
            switch result {
            case .success:
                print("arFile保存に成功")
            case let .failure(error):
                print("arFile:\(error)")
            }
        })
        
        
        // スクリプトインスタンスを生成
        let script = NCMBScript(name: "saveStick.js", method: .post)
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": user.objectId, "detail": detail, "fileName": fileName, "flag": 1]
        
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
    }
    
    private func getFileName(objectId: String) -> String {
        
        
        // 日付を取得
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
        print("date:\(dateFormatter.string(from: date))")
        
        // ファイル名を生成
        let fileName = "\(objectId).\(dateFormatter.string(from: date))"
        print(fileName)
        
        return fileName
    }
}
