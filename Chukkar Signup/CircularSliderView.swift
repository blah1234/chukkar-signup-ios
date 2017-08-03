//
//  CircularSliderView.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 7/18/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

@IBDesignable class CircularSliderView: UIView {

    @IBInspectable var startColor:UIColor = UIColor.red {
        didSet {
            sliderControl?.startColor = startColor
        }
    }
    
    @IBInspectable var endColor:UIColor = UIColor.blue {
        didSet {
            sliderControl?.endColor = endColor
        }
    }
    
    var angle: Int {
        get {
            return sliderControl?.angle ?? 0
        }
        
        set {
            sliderControl?.angle = newValue
        }
    }
    
    var totalDivisions: Int! {
        get {
            return sliderControl?.totalDivisions ?? 0
        }
        
        set {
            sliderControl?.totalDivisions = newValue
        }
    }
    
    var division: Int! {
        get {
            return sliderControl?.division ?? 0
        }
        
        set {
            sliderControl?.division = newValue
        }
    }
    
    private(set) var sliderControl: CircularSlider!
    
    
    
    
    #if TARGET_INTERFACE_BUILDER
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    
        let slider = CircularSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)
        slider.angle = 180
        self.addSubview(slider)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.prepareForInterfaceBuilder()
    }
    
    #else
    override var bounds: CGRect {
        didSet {
            sliderControl.frame = self.bounds
            sliderControl.bounds = self.bounds
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Build the slider
        sliderControl = CircularSlider(startColor:self.startColor, endColor:self.endColor, frame: self.bounds)
        
        // Attach an Action and a Target to the slider
        sliderControl.addTarget(self, action: #selector(valueChanged(slider:)), for: UIControlEvents.valueChanged)
        
        // Add the slider as subview of this view
        self.addSubview(sliderControl)
    }
    #endif
    

    
    func valueChanged(slider: CircularSlider) {
        // Do something with the value...
        
    }

}
