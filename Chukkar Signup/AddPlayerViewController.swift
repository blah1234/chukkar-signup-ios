//
//  AddPlayerViewController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 7/12/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class AddPlayerViewController: UIViewController, UITextFieldDelegate {

    struct Config {
        static let TAG_BOTTOM_BORDER = 100
    }
    
    struct Storyboard {
        static let unwindToHomeSegueId = "unwindToHome"
    }
    
    
    
    @IBOutlet weak var nameTextField: JVFloatLabeledTextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var chukkarsLabel: UILabel!
    @IBOutlet weak var chukkarsSlider: CircularSliderView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    var imageId: Int!
    var selectedDay: Day!
    var responseJSON: Any!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: localize strings
        self.navigationItem.title = "Sign Up"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onSignupComplete))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        nameTextField.becomeFirstResponder()
        nameTextField.delegate = self
        
        chukkarsLabel.textColor = nameTextField.floatingLabelTextColor
        chukkarsLabel.font = nameTextField.floatingLabelFont
        
        chukkarsSlider.startColor = chukkarsSlider.tintColor
        chukkarsSlider.endColor = chukkarsSlider.tintColor
        chukkarsSlider.totalDivisions = 12
        chukkarsSlider.division = 2
        
        
        let assetName = "cover\(imageId ?? 1)"
        backgroundImage.image = UIImage(named: assetName)!
        
        //too distracting
//        addParallaxToView(vw: backgroundImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chukkarsSlider.sliderControl.addTarget(self, action: #selector(onSliderTouchDown), for: .touchDown)
        chukkarsSlider.sliderControl.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpInside)
        chukkarsSlider.sliderControl.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpOutside)
        
        nameTextField.addTarget(self, action: #selector(onNameEditingChanged), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        chukkarsSlider.sliderControl.removeTarget(self, action: #selector(onSliderTouchDown), for: .touchDown)
        chukkarsSlider.sliderControl.removeTarget(self, action: #selector(onSliderTouchUp), for: .touchUpInside)
        chukkarsSlider.sliderControl.removeTarget(self, action: #selector(onSliderTouchUp), for: .touchUpOutside)
        
        nameTextField.removeTarget(self, action: #selector(onNameEditingChanged), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController || self.isBeingDismissed) {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setBottomBorder(nameTextField)
        setBottomBorder(chukkarsLabel)
        
        if nameTextField.floatingLabel.frame.origin.x > 0 {
            nameTextField.floatingLabelXPadding = -nameTextField.floatingLabel.frame.origin.x
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nameTextField.isEditing {
            nameTextField.endEditing(true)
        }
    }
    
    private func addParallaxToView(vw: UIView) {
        let amount = 200
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal]
        vw.addMotionEffect(group)
    }
    
    @objc private func onSliderTouchDown() {
        if nameTextField.isEditing {
            nameTextField.endEditing(true)
        }
        
        chukkarsLabel.textColor = chukkarsLabel.tintColor
    }
    
    @objc private func onSliderTouchUp() {
        chukkarsLabel.textColor = nameTextField.floatingLabelTextColor
    }
    
    @objc private func onNameEditingChanged() {
        if let length = nameTextField.text?.characters.count {
            self.navigationItem.rightBarButtonItem?.isEnabled = nameTextField.text != nil && length > 0
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func setBottomBorder(_ view: UIView) {
        if view.frame.width > 0 && view.frame.height > 0 {
            if let existBorder = view.viewWithTag(Config.TAG_BOTTOM_BORDER) {
                existBorder.removeFromSuperview()
            }
            
            let height = 1.0
            
            let borderLine = UIView()
            borderLine.tag = Config.TAG_BOTTOM_BORDER
            borderLine.frame = CGRect(x: 0, y: Double(view.frame.height) - height, width: Double(view.frame.width), height: height)
            
            borderLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            view.addSubview(borderLine)
        }
    }
    
    @objc private func onSignupComplete() {
        if nameTextField.isEditing {
            nameTextField.endEditing(true)
        }
        
        loading.startAnimating()
        
        blurEffect.effect = nil
        blurEffect.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffect.effect = UIBlurEffect(style: .light)
        }, completion: { (finished: Bool) in
            self.addPlayersAsync()
        })
    }
    
    private func addPlayersAsync() {
        let bodyData = Constants.Player.REQUESTDAY_FIELD + "=" + String(describing: selectedDay!)
            + "&" + Constants.Player.NAME_FIELD + "=" + nameTextField.text!
            + "&" + Constants.Player.NUMCHUKKARS_FIELD + "=" + String(chukkarsSlider.division)
        
        let requestURL: URL = URL(string: Constants.AddPlayerVeiwController.ADD_PLAYER_URL)!
        var urlRequest: URLRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            //because we're using the shared URLSession, the completion handler is NOT running on the main dispatch queue!
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200) {
                
                DispatchQueue.main.async {
                    do {
                        self.responseJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        self.performSegue(withIdentifier: Storyboard.unwindToHomeSegueId, sender: AddPlayerViewController.self)
                    } catch {
                        if let str = String.init(data: data!, encoding: .utf8) {
                            self.responseJSON = str
                            self.performSegue(withIdentifier: Storyboard.unwindToHomeSegueId, sender: AddPlayerViewController.self)
                        } else {
                            log.error("Error with parsing response data: \(data)")
                        }
                    }
                    
                    self.loading.stopAnimating()
                }
            }
        }
        
        task.resume()
    }

    

    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

