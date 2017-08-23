//
//  SignupDayViewController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/13/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

//Deprecated
class SignupDayViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var bannerWidth: NSLayoutConstraint!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var visualEffectBlur: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var pageIndex: Int = 0
    var displayedDay: Day!
    var players: [Player]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    static var usedImages = Set<Int>()
    
    struct Storyboard {
        static let cellId = "PlayerTableViewCell"
    }
    
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dayLabel.text = "\(displayedDay!)"
        
        let screenSize = UIScreen.main.bounds
        bannerWidth.constant = screenSize.width //constraint banner to be full screen width
        bannerImage.image = getImage()

        if let imgSize = bannerImage.image?.size {
            let aspectRatio = imgSize.height / imgSize.width
            let aspectHeight = bannerWidth.constant * aspectRatio
            bannerHeight.constant = aspectHeight
        }
        
        
        blurEffectView(enable: false)
        blurEffectView(enable: true)
        
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func getImage() -> UIImage {
        var id: Int
            
        repeat {
            id = Utils.randomInt(min: 1, max: Constants.SignupDayTableViewController.BANNER_IMAGE_COUNT)
        } while SignupDayViewController.usedImages.contains(id)
        
        SignupDayViewController.usedImages.insert(id)
        let assetName = "cover\(id)"
        return UIImage(named: assetName)!
    }
    
    
    
    private func blurEffectView(enable: Bool) {
        let enabled = self.visualEffectBlur.effect != nil
        guard enable != enabled else { return }
        
        switch enable {
        case true:
            let blurEffect = UIBlurEffect(style: .extraLight)
            UIView.animate(withDuration: 1.5) {
                self.visualEffectBlur.effect = blurEffect
            }
            
            self.visualEffectBlur.pauseAnimation(delay: 0.36)
        case false:
            self.visualEffectBlur.resumeAnimation()
            
            UIView.animate(withDuration: 0.1) {
                self.visualEffectBlur.effect = nil
            }
        }
    }
    
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (players?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellId, for: indexPath) as? PlayerTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlayerTableViewCell.")
        }
        
        let player = players?[indexPath.row]
        cell.player = player
        
        return cell
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

private extension UIView {
    
    func pauseAnimation(delay: Double) {
        let time = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }
    
    func resumeAnimation() {
        let pausedTime  = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
}
