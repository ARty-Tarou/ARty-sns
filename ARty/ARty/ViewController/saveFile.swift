import UIKit
import NCMB

class SaveFile{
    func saveFile(data: Data?){
        // スクリプトインスタンスの作成
        let script = NCMBScript(name: "saveFile.js", method: .post)
        // データをエンコード
        let data = data?.base64EncodedString()
        
        print("data:\(String(describing: data))")
        
        guard let user = NCMBUser.currentUser else{
            fatalError("カレントユーザー取得に失敗")
        }
        // ヘッダー設定
        let headers: [String: String?] = ["userName": user.userName, "password": user.password]
        
        // ボディ設定
        let requestBody: [String: Any?] = ["userId": user.objectId, "fileData": data]
        
        // スクリプト実行
        script.executeInBackground(headers: headers, queries: [:], body: requestBody, callback: {result in
            switch result{
            case let .success(data):
                print("script実行に成功:\(String(data: data ?? Data(), encoding: .utf8) ?? "" )")
            case let .failure(error):
                print("script実行に失敗\(error)")
            }
        })
    }
}

