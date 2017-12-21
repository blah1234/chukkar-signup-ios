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
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    weak var delegate: EditPlayerViewControllerDelegate?
    var player: Player! {
        didSet {
            if let slider = chukkarsSlider {
                slider.division = player.numChukkars
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chukkarsSlider.startColor = chukkarsSlider.tintColor
        chukkarsSlider.endColor = chukkarsSlider.tintColor
        chukkarsSlider.totalDivisions = 12
        chukkarsSlider.division = player.numChukkars
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
    
    @IBAction func dismissEdit() {
        //delegate is already set to nil by the time completion handler is executed
        let popoverDelegate = self.popoverPresentationController?.delegate
       
        self.dismiss(animated: true) {
            //https://developer.apple.com/documentation/uikit/uipopoverpresentationcontrollerdelegate/1622322-popoverpresentationcontrollerdid
            //The presentation controller calls this method only in response to user actions. It does not call this method if you dismiss the popover programmatically.
            popoverDelegate?.popoverPresentationControllerDidDismissPopover?(self.popoverPresentationController!)
        }
    }
    
    @IBAction func onEditComplete(_ sender: Any) {
        loading.startAnimating()

        blurEffect.effect = nil
        blurEffect.isHidden = false

        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffect.effect = UIBlurEffect(style: .light)
        }, completion: { (finished: Bool) in
            self.loading.stopAnimating()
            self.editChukkarsAsync()
        })
    }
    
    private func editChukkarsAsync() {
        let oldChukkars = player.numChukkars!
        let newChukkars = chukkarsSlider.division!
        
        if newChukkars != oldChukkars {
            let bodyData = Constants.Player.ID_FIELD + "=" + player!.id!
                + "&" + Constants.Player.NUMCHUKKARS_FIELD + "=" + String(newChukkars)
            
            let requestURL: URL = URL(string: Constants.EditPlayerViewController.EDIT_PLAYER_URL)!
            var urlRequest: URLRequest = URLRequest(url: requestURL)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = bodyData.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) {
                [weak self] (data, response, error) -> Void in
                
                //because we're using the shared URLSession, the completion handler is NOT running on the main dispatch queue!
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if(statusCode == 200) {
                    
                    DispatchQueue.main.async {
                        do {
                            let responseJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                            self?.sendNotification(withJsonPayload: responseJSON)
                        } catch {
                            if let str = String.init(data: data!, encoding: .utf8) {
                                self?.sendNotification(withJsonPayload: str)
                            } else {
                                log.error("Error with parsing response data: \(data as Optional)")
                            }
                        }
                    }
                }
            }
            
            delegate?.onEditChukkarsRequested(task: task)
        }
        
        self.dismissEdit()
    }
    
    private func sendNotification(withJsonPayload json: Any) {
        let dataDict = [Constants.Data.CONTENT_KEY: json]
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.EditPlayerViewController.EDIT_PLAYER_CHUKKARS_SUCCESS_KEY), object: self, userInfo: dataDict)
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


protocol EditPlayerViewControllerDelegate: NSObjectProtocol {
    func onEditChukkarsRequested(task: URLSessionDataTask)
}
