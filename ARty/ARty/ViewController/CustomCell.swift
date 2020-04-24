import UIKit

class CustomCell: UITableViewCell{
    
    // MARK: Properties
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var overViewTextField: UITextField!
    
    
    func set(userName: String, productImage: UIImage?){
        userNameLabel.text = userName
    }
}
