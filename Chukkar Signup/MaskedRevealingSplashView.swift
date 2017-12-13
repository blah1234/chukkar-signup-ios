//
//  RevealingSplashView.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 10/26/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

public typealias SplashAnimatableCompletion = () -> Void
public typealias SplashAnimatableExecution = () -> Void


class MaskedRevealingSplashView: UIView, CAAnimationDelegate {
    
    /// The duration of the animation, default to 1.5 seconds. In the case of heartBeat animation recommended value is 3
    open var duration: Double = 1.5
    
    /// The delay of the animation, default to 0.5 seconds
    open var delay: Double = 0.5
    
    /// The boolean to stop the heart beat animation, default to false (continuous beat)
    open var heartAttack: Bool = false
    
    /// The repeat counter for heart beat animation, default to 1
    open var minimumBeats: Int = 1
    
    
    
    public init(iconImage: UIImage, iconInitialSize:CGSize, backgroundColor: UIColor) {
        //Inits the view to the size of the screen
        super.init(frame: (UIScreen.main.bounds))
        
        self.backgroundColor = backgroundColor
        
        //see https://stackoverflow.com/a/42238699 and
        //https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIMaskToAlpha
        
        //first draw iconImage into a white background, sized to the screen
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(self.frame)
        
        // Draw the starting image, centered in the current context
        context.interpolationQuality = .high
        let sw = self.frame.width
        let sh = self.frame.height
        let iw = iconInitialSize.width
        let ih = iconInitialSize.height
        iconImage.draw(in: CGRect(x: (sw - iw)/2, y: (sh - ih)/2, width: iconInitialSize.width, height: iconInitialSize.height))
        
        // Save the context as a new UIImage
        let resizedIconImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        let image = CIImage(image: resizedIconImage)
        let filter = CIFilter(name: "CIMaskToAlpha")!
        filter.setValue(image, forKey: kCIInputImageKey)
        let result = filter.outputImage!
        let cgim = CIContext().createCGImage(result, from: result.extent)
        
        let mask = CALayer()
        mask.frame = UIScreen.main.bounds
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.contents = cgim
        
        self.layer.mask = mask
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    /**
     Plays the heatbeat animation with completion
     
     - parameter completion: completion
     */
    public func playHeartBeatAnimation(_ completion: SplashAnimatableCompletion? = nil) {
        let popForce = 0.8
        
        animateLayer({
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [0, 0.1 * popForce, 0.015 * popForce, 0.2 * popForce, 0]
            animation.keyTimes = [0, 0.25, 0.35, 0.55, 1]
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.duration = CFTimeInterval(self.duration/2)
            animation.isAdditive = true
            animation.repeatCount = Float(minimumBeats > 0 ? minimumBeats : 1)
            animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/2)
            self.layer.add(animation, forKey: "pop")
        }, completion: { [weak self] in
            if self?.heartAttack ?? true {
                self?.playZoomOutAnimation(completion)
            } else {
                self?.playHeartBeatAnimation(completion)
            }
        })
    }
    
    /**
     Plays the zoom out animation with completion
     
     - parameter completion: completion
     */
    public func playZoomOutAnimation(_ completion: SplashAnimatableCompletion? = nil)
    {
//        let growDuration: TimeInterval =  duration * 0.3
//        
//        UIView.animate(withDuration: growDuration, animations:{
//            
//            self.transform = self.getZoomOutTranform()
//            
//            //When animation completes remote self from super view
//        }, completion: { finished in
//            
//            self.removeFromSuperview()
//            
//            completion?()
//        })
        
//        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
//        keyFrameAnimation.delegate = self
//        keyFrameAnimation.duration = 10
//        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
//        let initalBounds = NSValue(cgRect: self.layer.mask!.bounds)
//        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 90, height: 90))
//        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
//        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
//        keyFrameAnimation.keyTimes = [0, 3, 10]
//        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
//        self.layer.mask?.add(keyFrameAnimation, forKey: "bounds")
        
        
        let oldBounds = layer.mask!.bounds
        let newBounds = CGRect(x: 0, y: 0, width: frame.width * 10, height: frame.height * 10)
        let revealAnimation = CABasicAnimation(keyPath: "bounds")
        revealAnimation.delegate = self
        revealAnimation.fromValue = NSValue(cgRect: oldBounds)
        revealAnimation.toValue = NSValue(cgRect: newBounds)
        revealAnimation.duration = 10
        self.layer.mask?.add(revealAnimation, forKey: "bounds")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.layer.mask = nil //remove mask when animation completes
    }
    
    /**
     Stops the heart beat animation after gracefully finishing the last beat
     
     This function will not stop the original completion block from getting called
     */
    public func finishHeartBeatAnimation() {
        self.heartAttack = true
    }
    
    
    
    // MARK: - Private
    fileprivate func animateLayer(_ animation: SplashAnimatableExecution, completion: SplashAnimatableCompletion? = nil) {
        
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock { completion() }
        }
        animation()
        CATransaction.commit()
    }

    /**
     Retuns the default zoom out transform to be use mixed with other transform
     
     - returns: ZoomOut fransfork
     */
    fileprivate func getZoomOutTranform() -> CGAffineTransform
    {
        let zoomOutTranform: CGAffineTransform = CGAffineTransform(scaleX: 20, y: 20)
        return zoomOutTranform
    }
}
