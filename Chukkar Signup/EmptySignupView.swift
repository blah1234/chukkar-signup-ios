//
//  EmptySignupView.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 11/20/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class EmptySignupView: UIButton {
    
    @IBOutlet var button: UIButton!
    var paddingTop: CGFloat? {
        didSet {
//            button?.contentEdgeInsets = UIEdgeInsetsMake(paddingTop!, 0, 0, 0)
//            button?.frame = button!.frame.offsetBy(dx: 0, dy: paddingTop!)
//            button?.frame = bounds.insetBy(dx: 0, dy: 1)
        }
    }
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    private func setup() {
        button = loadViewFromNib() as! UIButton!
        button.frame = bounds
        
        if let top = paddingTop {
//            button.contentEdgeInsets = UIEdgeInsetsMake(top, 0, 0, 0)
//            button.frame = button.frame.offsetBy(dx: 0, dy: top)
//            button.frame = bounds.insetBy(dx: 0, dy: paddingTop!)
        }
        
        button.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(button)
    }
    
    private func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
        
        return view
    }
}
