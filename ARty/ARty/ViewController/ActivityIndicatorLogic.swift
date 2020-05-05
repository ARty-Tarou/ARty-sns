import UIKit

class ActivityIndicatorLogic{
    
    var activityIndicator = UIActivityIndicatorView()
    
    init(view: UIView){
        self.activityIndicator.color = .gray
        self.activityIndicator.center = view.center
        self.activityIndicator.style = .large
        
        view.addSubview(activityIndicator)
    }
    
    func startActivityIndecator(view: UIView){
        print("処理中です")
        // ActivityIndicatorを開始、操作を不可にする
        DispatchQueue.global().async{
            DispatchQueue.main.async{
                self.activityIndicator.startAnimating()
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    func stopActivityIndecator(view: UIView){
        // ActivityIndicatorを終了、操作を可能にする
        DispatchQueue.global().async{
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
            }
        }
    }
}
