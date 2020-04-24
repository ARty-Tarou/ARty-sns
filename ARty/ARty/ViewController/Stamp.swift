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
    var name: String
    var image: UIImage?

    // MARK: Initialization
    init?(name: String, image: UIImage?) {
    
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // Initialize stored properties
        self.name = name
        self.image = image
    }
}
