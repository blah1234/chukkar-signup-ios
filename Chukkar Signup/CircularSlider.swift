//
//  CircularSlider.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 7/17/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit
import AudioToolbox

class CircularSlider: UIControl {

    struct Config {
        static let TB_SAFEAREA_PADDING:CGFloat = 30.0
        static let TB_BACKGROUND_WIDTH:CGFloat = 10.0
        static let TB_LINE_WIDTH:CGFloat = 14.0
        static let TB_FONTSIZE:CGFloat = 50.0
    }
    
    
    // MARK: Math Helpers
    func DegreesToRadians(_ value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    func RadiansToDegrees(_ value:Double) -> Double {
        return value * 180.0 / M_PI
    }
    
    func Square(_ value:CGFloat) -> CGFloat {
        return value * value
    }
    
    
    var totalDivisions: Int = 360 {
        didSet {
            updateTextField()
        }
    }
    
    var division: Int {
        get {
            return angle / (360/totalDivisions)
        }
        
        set {
            angle = newValue * (360/totalDivisions)
        }
    }
    
    var textField: UITextField!
    var radius: CGFloat = 0
    var startColor = UIColor.red {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var endColor = UIColor.blue {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var angle: Int {
        get {
            var helper = -self.internalAngle + 90
            
            if helper < 0 {
                helper += 360
            }
            
            return helper
        }
        
        set {
            self.internalAngle = -newValue + 90
            
            if self.internalAngle < 0 {
                internalAngle += 360
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            onBoundsChanged()
        }
    }
    

    private var internalAngle: Int = 90 {
        didSet {
            updateTextField()
        }
    }
    
    
    
    // MARK: Custom initializer
    convenience init(startColor: UIColor, endColor: UIColor, frame: CGRect){
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // MARK: Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        
        onBoundsChanged()
    }
    
    private func onBoundsChanged() {
        textField?.removeFromSuperview()
        
        //Define the circle radius taking into account the safe area
        radius = min(self.bounds.width, self.bounds.height)/2 - Config.TB_SAFEAREA_PADDING
        
        //Define the Font
        let font = UIFont(name: "HelveticaNeue-UltraLight", size: Config.TB_FONTSIZE)
        //Calculate font size needed to display 2 numbers
        let str = "000" as NSString
        let fontSize:CGSize = str.size(attributes: [NSFontAttributeName:font!])
        
        //Using a TextField area we can easily modify the control to get user input from this field
        let textFieldRect = CGRect(x: (bounds.width  - fontSize.width) / 2.0,
                                   y: (bounds.height - fontSize.height) / 2.0,
                                   width: fontSize.width,
                                   height: fontSize.height)
        
        textField = UITextField(frame: textFieldRect)
        textField.backgroundColor = UIColor.clear
        textField.textAlignment = .center
        textField.font = font
        updateTextField()
        
        addSubview(textField)
        self.setNeedsDisplay()
    }
    
    private func updateTextField() {
        let newText = "\(angle / (360/totalDivisions))"
        
        if newText != textField.text {
            textField.text = newText
            
            let gen = UISelectionFeedbackGenerator()
            gen.selectionChanged()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let lastPoint = touch.location(in: self)
        
        self.moveHandle(lastPoint: lastPoint)
        
        self.sendActions(for: UIControlEvents.valueChanged)
        
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }

    
    //Use the draw rect to draw the Background, the Circle and the Handle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        /** Draw the Background **/
        ctx?.addArc(center: self.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: false)
        ctx?.setStrokeColor(gray: 0.5, alpha: 0.5)
        
        ctx?.setLineWidth(Config.TB_BACKGROUND_WIDTH)
        ctx?.setLineCap(.butt)

        ctx?.drawPath(using: .stroke)
        
        
        /** Draw the circle **/
        
        /** Create THE MASK Image **/
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        let imageCtx = UIGraphicsGetCurrentContext()
        imageCtx?.addArc(center: self.center, radius: radius, startAngle: CGFloat(Double(0) + M_PI/2), endAngle: CGFloat(DegreesToRadians(Double(self.internalAngle))), clockwise: true)
        imageCtx?.setFillColor(UIColor.red.cgColor)
        imageCtx?.setStrokeColor(UIColor.red.cgColor)
        imageCtx?.setLineCap(.round)

        
        //Use shadow to create the Blur effect
        imageCtx?.setShadow(offset: CGSize(width: 0, height: 0), blur: CGFloat(self.angle/10), color: UIColor.black.cgColor)
        
        //define the path
        imageCtx?.setLineWidth(Config.TB_LINE_WIDTH)
        imageCtx?.drawPath(using: .stroke)
        
        //save the context content into the image mask
        let mask = (imageCtx?.makeImage())!
        UIGraphicsEndImageContext();
        
        /** Clip Context to the mask **/
        ctx?.saveGState()

        ctx?.clip(to: self.bounds, mask: mask)
        
        
        /** The Gradient **/
        
        // Split colors in components (rgba)
        let startColorComps = startColor.cgColor.components!;
        let endColorComps = endColor.cgColor.components!;
        
        let components : [CGFloat] = [
            startColorComps[0], startColorComps[1], startColorComps[2], 1.0,     // Start color
            endColorComps[0], endColorComps[1], endColorComps[2], 1.0      // End color
        ]
        
        // Setup the gradient
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: baseSpace, colorComponents: components, locations: nil, count: 2)
        
        // Gradient direction
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        // Draw the gradient
        ctx?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        ctx?.restoreGState()
        
        /* Draw the handle */
        drawTheHandle(ctx)
    }
    

    /** Draw a white knob over the circle **/
    
    func drawTheHandle(_ ctx: CGContext?) {
        
        ctx?.saveGState();
        
        //I Love shadows
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 3, color: UIColor.black.cgColor);
        
        //Get the handle position
        let handleCenter = pointFromAngle(internalAngle)
        
        //Draw It!
        UIColor(white:1.0, alpha:0.7).set();
        ctx?.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: Config.TB_LINE_WIDTH, height: Config.TB_LINE_WIDTH));
        
        ctx?.restoreGState();
    }
    
    
    /** Move the Handle **/
    
    func moveHandle(lastPoint: CGPoint) {
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle:Double = AngleFromNorth(p1: self.center, p2: lastPoint, flipped: false);
        let angleInt = Int(floor(currentAngle))
        
        //Store the new angle
        internalAngle = Int(360 - angleInt)
        
        if internalAngle < 0 {
            internalAngle = internalAngle + 360
        }
        
        
        //Redraw
        setNeedsDisplay()
    }
    
    
    /** Given the angle, get the point position on circumference **/
    func pointFromAngle(_ angleInt: Int) -> CGPoint {
        //Circle center
        let centerPoint = CGPoint(x: self.bounds.midX - Config.TB_LINE_WIDTH/2.0, y: self.bounds.midY - Config.TB_LINE_WIDTH/2.0);
        
        //The point position on the circumference
        var result:CGPoint = CGPoint.zero
        let y = round(Double(radius) * sin(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.y)
        let x = round(Double(radius) * cos(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result;
    }
    
    
    //Sourcecode from Apple example clockControl
    //Calculate the direction in degrees from a center point to an arbitrary position.
    func AngleFromNorth(p1: CGPoint, p2: CGPoint, flipped: Bool) -> Double {
        var v:CGPoint  = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag:CGFloat = Square(Square(v.x) + Square(v.y))
        var result:Double = 0.0
        v.x /= vmag;
        v.y /= vmag;
        let radians = Double(atan2(v.y,v.x))
        result = RadiansToDegrees(radians)
        return (result >= 0  ? result : result + 360.0);
    }

}
