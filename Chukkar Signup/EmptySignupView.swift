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
class EmptySignupView: UIView {
    
    @IBOutlet var button: UIButton!
    
    var offsetY: CGFloat? {
        didSet {
            updateButtonFrame()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateButtonFrame()
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
        button = loadViewFromNib() as! UIButton
        button.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(button)
        updateButtonFrame()
    }
    
    private func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
        
        return view
    }
    
    private func updateButtonFrame() {
        button?.frame = CGRect(x: 0, y: -self.frame.origin.y + (offsetY ?? 0), width: self.bounds.width, height: button.intrinsicContentSize.height)
    }
}
