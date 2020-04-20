//
//  ChangeSettingViewController.swift
//  ARty
//
//  Created by 石松祐太 on 2020/04/20.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit

class ChangeSettingViewController: UIViewController {
    @IBOutlet weak var UserName: UILabel!
    @IBAction func NewUser(_ sender: UITextField) {
        UserName.text = sender.text
    }
    @IBOutlet weak var Appeal: UILabel!
    @IBAction func SelfIntroduction(_ sender: UITextField) {
        Appeal.text = sender.text
    }
    @IBOutlet weak var UserImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
