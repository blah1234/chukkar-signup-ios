//
//  ViewController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/7/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit
import Foundation
import os.log
import RevealingSplashView
import MaterialComponents


class MainViewController: UIViewController, UIPageViewControllerDataSource, SignupDayTableViewControllerDelegate {

    // The custom UIPageControl
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    private var splash: RevealingSplashView!
    private var blurEffectView: UIVisualEffectView!
    private var addPlayerButton: MDCFloatingButton!
    
    // The UITabBarController
    private var mPageContainer: UITabBarController!
    
    // The pages it contains
    private var mDays = Array<Day>()
    
    
    private var mData: [Day: [Player]]?
    
    struct Storyboard {
        static let launchScreenName = "LaunchScreen"
        static let logoInitialSize = 90
        static let addPlayerSegueId = "addPlayer"
        static let signupDayControllerId = "SignupDayTableViewController"
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let navCtrl = self.navigationController as! ObservedNavigationController
//        navCtrl.observedDelegate = self
        
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        
        // Create the page container
        mPageContainer = UITabBarController()
        
        // Add it to the view
        view.addSubview(mPageContainer.view)
        mPageContainer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mPageContainer.view.frame = view.bounds
        
        //put splash on top of everything
        initSplash()
        
        
        
        loadActiveDaysAsync()
        
        
        // listen for edit player notification key
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditPlayerChukkarsSuccess(_:)), name: NSNotification.Name(rawValue: Constants.EditPlayerViewController.EDIT_PLAYER_CHUKKARS_SUCCESS_KEY), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //now handled in the completion block of the splash screen animation. See initSplash()
//        blurEffectView?.removeFromSuperview()
//        addStatusBarBlurEffect()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Methods
    private func initSplash() {
        let launchScreen = UIStoryboard(name: Storyboard.launchScreenName, bundle: nil).instantiateInitialViewController()
        let launchView = launchScreen!.view!
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        splash = RevealingSplashView(iconImage: #imageLiteral(resourceName: "logo"), iconInitialSize: CGSize(width: Storyboard.logoInitialSize, height: Storyboard.logoInitialSize), backgroundColor: launchView.backgroundColor!)
        
        splash.animationType = .heartBeat
        splash.duration = 2
        splash.delay = 0.9
        splash.minimumBeats = 1
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(splash)
        
        //Starts animation
        splash.startAnimation() {
            log.info("Splash Completed")
            self.blurEffectView?.removeFromSuperview()
            self.addStatusBarBlurEffect()
        }
    }
    
    private func initAddPlayerButton() {
        if addPlayerButton == nil {
            addPlayerButton = MDCFloatingButton()
            mPageContainer.view.addSubview(addPlayerButton)
            
            addPlayerButton.translatesAutoresizingMaskIntoConstraints = false
            let horizConstraint = addPlayerButton.trailingAnchor.constraint(equalTo: mPageContainer.view.trailingAnchor, constant: -mPageContainer.view.layoutMargins.right)
            let vertConstraint = addPlayerButton.bottomAnchor.constraint(equalTo: mPageContainer.tabBar.topAnchor, constant: -mPageContainer.view.layoutMargins.right)
            mPageContainer.view.addConstraints([horizConstraint, vertConstraint])
            
            
            var addImage = UIImage.imageFromSystemBarButton(.add, renderingMode: .alwaysTemplate)
            addImage = addImage.maskWithColor(color: UIColor.white)
            addPlayerButton.setImage(addImage, for: .normal)
            addPlayerButton.sizeToFit()
            addPlayerButton.addTarget(self, action: #selector(segueToAddPlayer), for: .touchUpInside)
        }
    }
    
    private func queryWebAppResetDate() {
        let requestURL: URL = URL(string: "http://malapropism2.appspot.com/signup/json/getResetDate")!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) {
                var dateStr = String.init(data: data!, encoding: String.Encoding.utf8)
                dateStr = dateStr?.trimmingCharacters(in: CharacterSet.init(charactersIn: "\""))
                
                let dateFormat = DateFormatter()
                dateFormat.locale = Locale(identifier: "en_US")
                dateFormat.dateFormat = "MMM dd, yyyy hh:mm:ss a"
                dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
                
                if let resetDate = dateFormat.date(from: dateStr!) {
                    let prevResetDate = self.getPreviousWebAppResetDate()
                    
                    if(prevResetDate == nil || resetDate > prevResetDate!) {
                        self.writeResetDate(dateStr!)
                        
                        if(prevResetDate != nil) {
                            self.resetAllCachedData()
                        }
                    }
                }
                
                
                self.loadPlayersAsync()
            }
        }
        
        task.resume()
    }
    
    private func getPreviousWebAppResetDate() -> Date? {
        let userDefaults = UserDefaults.standard
        
        let resetDate = userDefaults.string(forKey: Constants.Data.RESET_DATE_KEY)
        
        if resetDate != nil {
            let dateFormat = DateFormatter()
            dateFormat.locale = Locale(identifier: "en_US")
            dateFormat.dateFormat = "MMM dd, yyyy hh:mm:ss a"
            dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
            
            if let prevResetDate = dateFormat.date(from: resetDate!) {
                return prevResetDate
            } else {
                //this means date in the file is corrupted somehow. Go ahead and
                //return null, so the file will overwritten with fresh data.
                let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "app init")
                os_log("unable to parse previous reset date stored in user defaults: %@", log: log, type: .info, resetDate!)
            }
        }
        
        return nil
    }
    
    private func writeResetDate(_ resetDate: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(resetDate, forKey: Constants.Data.RESET_DATE_KEY)
        userDefaults.synchronize()
    }
    
    private func resetAllCachedData() {
        //also erase the active days data
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: Constants.Data.ACTIVE_DAYS_KEY)
    
        //------------
    
        resetCachedPlayerSignups()
    }
    
    private func resetCachedPlayerSignups() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: Constants.Data.CONTENT_KEY)
        userDefaults.removeObject(forKey: Constants.Data.LAST_MODIFIED_KEY)
        
        // Commit the edits!
        userDefaults.synchronize()
    }

    private func loadActiveDaysAsync() {
        let requestURL: URL = URL(string: Constants.MainViewController.ACTIVE_DAYS_URL)!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    if let days = json as? [String] {
                        self.mDays.removeAll()
                        
                        for currDay in days {
                            self.mDays.append(Day.valueOf(name: currDay))
                        }
                        
                        self.mDays.sort()
                        
                        var controllers = [SignupDayTableViewController]()
                        
                        for index in 0..<self.mDays.count {
                            controllers.append(self.createViewControllerAtIndex(index))
                        }
                        
                        DispatchQueue.main.async {
                            SignupDayTableViewController.resetUsedImages()
                            self.mPageContainer.setViewControllers(controllers, animated: true)
                            self.mPageContainer.tabBar.isHidden = self.mDays.count == 1
                        }
                        
                        
                        self.loadPlayersAsync()
                    }
                } catch {
                    log.error("Error with parsing response data to Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    private func loadPlayersAsync() {
        let requestURL: URL = URL(string: Constants.MainViewController.GET_PLAYERS_URL)!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            //because we're using the shared URLSession, the completion handler is NOT running on the main dispatch queue!
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    self.parsePlayers(json: json, scrollToBottom: false)
                } catch {
                    log.error("Error with parsing response data to Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    private func parsePlayers(json: Any, scrollToBottom: Bool) {
        //TODO: debug only
//        log.debug(json)
        
        if let allData = json as? [String: AnyObject] {
            if let players = allData[Constants.Player.PLAYERS_LIST_FIELD] as? [[String: AnyObject]] {
                var dataHelper = [Day: [Player]]()
                
                for player in players {
                    let id = String(player[Constants.Player.ID_FIELD] as! Int)
                    let numChukkars = player[Constants.Player.NUMCHUKKARS_FIELD] as! Int
                    let requestDay = Day.valueOf(name: player[Constants.Player.REQUESTDAY_FIELD] as! String)
                    let name = player[Constants.Player.NAME_FIELD] as! String
                    
                    let dateStr = player[Constants.Player.CREATEDATE_FIELD] as! String
                    let dateFormat = DateFormatter()
                    dateFormat.locale = Locale(identifier: "en_US")
                    dateFormat.dateFormat = "MMM dd, yyyy hh:mm:ss a"
                    dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let createDate = dateFormat.date(from: dateStr)!
                    
                    let currPlayer = Player(createDate: createDate, id: id, name: name, numChukkars: numChukkars, requestDay: requestDay)
                    
                    
                    if dataHelper[requestDay] == nil {
                        dataHelper[requestDay] = [Player]()
                    }
                    
                    dataHelper[requestDay]?.append(currPlayer)
                }
                
                
                DispatchQueue.main.async {
                    self.mData = dataHelper
                    
                    for currCtrl in self.mPageContainer.viewControllers ?? [] {
                        if let currSigupCtrl = currCtrl as? SignupDayTableViewController {
                            currSigupCtrl.players = self.mData?[currSigupCtrl.displayedDay]
                        }
                    }
                    
                    if let currSigupCtrl = self.mPageContainer.selectedViewController as? SignupDayTableViewController {
                        if scrollToBottom {
                            currSigupCtrl.scrollToBottom()
                        }
                    }
                    
                    
                    
                    self.activityIndicator.stopAnimating()
                    self.splash.finishHeartBeatAnimation()
                    self.initAddPlayerButton()
                }
            }
        } else if let dataStr = json as? String {
            if Constants.Data.SIGNUP_CLOSED == dataStr {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.splash.finishHeartBeatAnimation()
                    var title: String? = nil
                    
                    if let currSigupCtrl = self.mPageContainer.selectedViewController as? SignupDayTableViewController {
                        title = String(describing: currSigupCtrl.displayedDay!)
                    }
                    
                    let alert = UIAlertController(title: title, message: NSLocalizedString("alert-message-signupClosed", comment: "Alert Message: Signup closed to all additions or edits"), preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: NSLocalizedString("alert-action-ok", comment: "Alert action: OK (positive) action"), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func handleEditPlayerChukkarsSuccess(_ notification: NSNotification) {
        if let json = notification.userInfo?[Constants.Data.CONTENT_KEY] {
            parsePlayers(json: json, scrollToBottom: false)
        }
    }
    
    private func createViewControllerAtIndex(_ index: NSInteger) -> SignupDayTableViewController {
        // Create a new view controller and pass suitable data.
        let signupDayViewController = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.signupDayControllerId) as! SignupDayTableViewController
        signupDayViewController.displayedDay = mDays[index]
        signupDayViewController.pageIndex = index
        signupDayViewController.players = mData?[mDays[index]]
        signupDayViewController.delegate = self
        
        return signupDayViewController
    }
    
    private func addStatusBarBlurEffect() {
        let bounds = UIApplication.shared.statusBarFrame
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = bounds
        
        self.view.addSubview(blurEffectView)
        
        blurEffectView(enable: false)
        blurEffectView(enable: true)
    }
    
    private func blurEffectView(enable: Bool) {
        let enabled = blurEffectView.effect != nil
        guard enable != enabled else { return }
        
        switch enable {
        case true:
            let blurEffect = UIBlurEffect(style: .light)
            UIView.animate(withDuration: 1.5) {
                self.blurEffectView.effect = blurEffect
            }
            
            blurEffectView.pauseAnimation(delay: 0.5)
        case false:
            blurEffectView.resumeAnimation()
            
            UIView.animate(withDuration: 0.1) {
                self.blurEffectView.effect = nil
            }
        }
    }
    
    
    // MARK: - Unwind segues
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        if let addCtrl = segue.source as? AddPlayerViewController {
            parsePlayers(json: addCtrl.responseJSON, scrollToBottom: true)
        }
    }
    
    
    
    // MARK: - UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageContent = viewController as? SignupDayTableViewController {
            var index = pageContent.pageIndex
        
            if ((index == 0) || (index == NSNotFound)) {
                return nil
            }
        
            index -= 1;
        
            return createViewControllerAtIndex(index)
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageContent = viewController as? SignupDayTableViewController {
            var index = pageContent.pageIndex
            if (index == NSNotFound) {
                return nil;
            }
        
            index += 1;
        
            if (index >= mDays.count) {
                return nil;
            }
        
            return createViewControllerAtIndex(index)
        } else {
            return nil;
        }
    }
    
    
    // MARK: - SignupDayTableViewController delegate
    func refreshSignups() {
        loadActiveDaysAsync()
    }
    
    func segueToAddPlayer() {
        performSegue(withIdentifier: Storyboard.addPlayerSegueId, sender: self)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if Storyboard.addPlayerSegueId == segue.identifier {
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                        
            
            if let currSignupCtrl = mPageContainer.selectedViewController as? SignupDayTableViewController {
                if let addCtrl = segue.destination as? AddPlayerViewController {
                    addCtrl.imageId = currSignupCtrl.imageId
                    addCtrl.selectedDay = currSignupCtrl.displayedDay
                }
            }
        }
    }
    
    
    // MARK: - ObservedNavigationController delegate
    
//    func navigationBarVisibilityDidChange(isHidden: Bool) {
//        if isHidden {
//            let when = DispatchTime.now() + Double(UINavigationControllerHideShowBarDuration * 2)
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                self.view.bringSubview(toFront: self.blurEffectView)
//            }
//        } else {
//            self.view.sendSubview(toBack: self.blurEffectView)
//        }
//
//        DispatchQueue.main.async {
//            let pageContent = self.mPageContainer.viewControllers?.first as! SignupDayTableViewController
//            pageContent.setHeaderTextTitleHidden(!isHidden)
//        }
//    }
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


private extension UIImage {
    
    class func imageFromSystemBarButton(_ systemItem: UIBarButtonSystemItem, renderingMode:UIImageRenderingMode = .automatic)-> UIImage {
        
        let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        
        // add to toolbar and render it
        UIToolbar().setItems([tempItem], animated: false)
        
        // got image from real uibutton
        let itemView = tempItem.value(forKey: "view") as! UIView
        
        for view in itemView.subviews {
            if view is UIButton {
                let button = view as! UIButton
                let image = button.imageView!.image!
                image.withRenderingMode(renderingMode)
                return image
            }
        }
        
        return UIImage()
    }
    
    
    func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}


