//
//  EditPlayerViewController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 8/3/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

class EditPlayerViewController: UIViewController {

    @IBOutlet weak var chukkarsSlider: CircularSliderView!
    
    var numChukkars: Int! {
        didSet {
            if let slider = chukkarsSlider {
                slider.division = numChukkars
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chukkarsSlider.startColor = chukkarsSlider.tintColor
        chukkarsSlider.endColor = chukkarsSlider.tintColor
        chukkarsSlider.totalDivisions = 12
        chukkarsSlider.division = numChukkars
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let popoverCtrl = self.popoverPresentationController {
            if let anchor = popoverCtrl.sourceView {
                switch popoverCtrl.arrowDirection {
                case UIPopoverArrowDirection.right:
                    popoverCtrl.sourceRect = CGRect(x: 0, y: anchor.bounds.midY, width: 0, height: 0)
                case UIPopoverArrowDirection.up:
                    popoverCtrl.sourceRect = CGRect(x: anchor.bounds.midX, y: anchor.bounds.height, width: 0, height: 0)
                case UIPopoverArrowDirection.down:
                    popoverCtrl.sourceRect = CGRect(x: anchor.bounds.midX, y: 0, width: 0, height: 0)
                default:    //.left
                    popoverCtrl.sourceRect = CGRect(x: anchor.bounds.width, y: anchor.bounds.midY, width: 0, height: 0)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
