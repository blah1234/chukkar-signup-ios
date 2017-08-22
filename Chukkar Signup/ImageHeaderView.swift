//
//  ImageHeaderView.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/23/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

class ImageHeaderView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelBottom: NSLayoutConstraint!
    
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            } else {
                imageView.image = nil
            }
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}
