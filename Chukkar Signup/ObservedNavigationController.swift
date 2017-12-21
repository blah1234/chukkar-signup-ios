//
//  ObservedNavigationController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/23/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

class ObservedNavigationController: UINavigationController {
    
    weak var observedDelegate: ObservedNavigationControllerDelegate?
    
    
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        observedDelegate?.navigationBarVisibilityDidChange(isHidden: hidden)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

protocol ObservedNavigationControllerDelegate: NSObjectProtocol {
    func navigationBarVisibilityDidChange(isHidden: Bool)
}
