//
//  ARStickViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/08/17.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import ReplayKit

class ARStickViewController: UIViewController, RPPreviewViewControllerDelegate {
    
    // MARK: Properties
    // appDelegate
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var ssImage: UIButton!
    
    // スクリーンサイズ
    var screenHeight = Int(UIScreen.main.bounds.size.height)
    var screenWidth = Int(UIScreen.main.bounds.size.width)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: Method
    
    func getScreenShot(windowFrame: CGRect) -> UIImage {
        // スクリーンショットを取得
        let sceneView = appDelegate.sceneView
        let image = sceneView!.snapshot()
        
        print("ss:\(image)")
        return image
    }
    
    // MARK: Action
    
    @IBAction func ssButtonAction(_ sender: Any) {
        
        // スクリーンショットを取得
        let image = getScreenShot(windowFrame: self.view.bounds)
        
        ssImage.setImage(image, for: .normal)
        
        
    }
    
}
