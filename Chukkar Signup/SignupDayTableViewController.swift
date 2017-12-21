//
//  SignupDayTableViewController.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/23/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

class SignupDayTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, EditPlayerViewControllerDelegate {

    weak var delegate: SignupDayTableViewControllerDelegate?
    var pageIndex: Int = 0
    var displayedDay: Day!
    var image: UIImage?
    var players: [Player]? {
        didSet {
            tableView?.reloadData()
        }
    }
    var imageId: Int {
        get {
            return _imageId ?? 0;
        }
    }
    
    //MARK: - Private
    
    private var tableHeaderViewHeight: CGFloat!
    private let tableHeaderViewCutaway: CGFloat = 40.0
    private var _imageId: Int?
    private var isRefreshRequested: Bool = false
    private var editChukkarsTask: URLSessionDataTask?
    
    private var headerView: ImageHeaderView!
    private var headerMaskLayer: CAShapeLayer!
    
    struct Storyboard {
        static let editPlayerSegueId = "editPlayer"
        static let cellId = "PlayerTableViewCell"
    }

    
    static private var usedImages = Set<Int>()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image = getImage()
        
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let screenSize = UIScreen.main.bounds
        
        if let imgSize = image?.size {
            let aspectRatio = imgSize.height / imgSize.width
            tableHeaderViewHeight = screenSize.width * aspectRatio  //constrain image to be full screen width
        }
        
        
        headerView = tableView.tableHeaderView as! ImageHeaderView
        headerView.image = image
        headerView.title = "\(displayedDay!)"
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        // cut away the header view
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        
        let effectiveHeight = tableHeaderViewHeight - tableHeaderViewCutaway/2
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        headerView.titleLabelBottom.constant -= tableHeaderViewCutaway
        
        updateHeaderView()
        
        
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        tableView.refreshControl = rc
        tableView.bringSubview(toFront: rc)
        
        
        
        //empty view
        let emptyView = EmptySignupView()
        emptyView.offsetY = tableHeaderViewCutaway
        emptyView.button.addTarget(self, action: #selector(requestAddPlayerSegue), for: .touchUpInside)
        tableView.backgroundView = emptyView
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc private func refresh(refreshControl: UIRefreshControl) {
        isRefreshRequested = true;
        
        //control then goes to scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    }
    
    @objc private func requestAddPlayerSegue() {
        delegate?.segueToAddPlayer()
    }
    
    func updateHeaderView() {
        let effectiveHeight = tableHeaderViewHeight - tableHeaderViewCutaway/2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderViewHeight)
        
        //stretching down
        if tableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + tableHeaderViewCutaway/2
            
            
            //make header image translucent, so RefreshControl is easier to see
            let screenSize = UIScreen.main.bounds
            var alpha = (screenSize.height/4.0 + tableView.contentOffset.y + effectiveHeight) / (screenSize.height/4.0)
            alpha = max(0.15, alpha)
            headerView.imageView.alpha = alpha
        } else {
            headerView.imageView.alpha = 1
        }
        
        headerView.frame = headerRect
        
        //trace out cutout image to display
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))  //start at origin
        path.addLine(to: CGPoint(x: headerRect.width, y: 0)) //move to top-right
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height - tableHeaderViewCutaway/2))    //move to bottom-right
        path.addCurve(to: CGPoint(x: 0, y: headerRect.height - tableHeaderViewCutaway), controlPoint1: CGPoint(x: headerRect.width*1/2, y: headerRect.height - tableHeaderViewCutaway), controlPoint2: CGPoint(x: headerRect.width*3/2, y: headerRect.height + tableHeaderViewCutaway))
//        path.addLine(to: CGPoint(x: 0, y: headerRect.height - tableHeaderViewCutaway))   //move to bottom-left
        
        headerMaskLayer?.path = path.cgPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SignupDayViewController.usedImages.insert(_imageId!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if _imageId != nil {
            SignupDayViewController.usedImages.remove(_imageId!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    static func resetUsedImages() {
        usedImages.removeAll()
    }
    
    private func getImage() -> UIImage {
        var id: Int
        
        repeat {
            id = Utils.randomInt(min: 1, max: Constants.SignupDayTableViewController.BANNER_IMAGE_COUNT)
        } while SignupDayViewController.usedImages.contains(id)
        
        _imageId = id
        SignupDayViewController.usedImages.insert(id)
        let assetName = "cover\(id)"
        return UIImage(named: assetName)!
    }
    
    func scrollToBottom() {
        if players != nil {
            let indexPath = IndexPath(row: players!.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func createImage(withView view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    private func getColor(withLabelText text: String, textColor: UIColor, bgColor: UIColor, height: CGFloat) -> UIColor {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: height, height: height))
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.textColor = textColor
        label.backgroundColor = bgColor
        
        return UIColor(patternImage: createImage(withView: label))
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefreshRequested && !tableView.isDragging {
            isRefreshRequested = false
            delegate?.refreshSignups()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        
        //parallax scrolling down
        headerView.imageTop?.constant = max(0, (scrollView.contentInset.top + scrollView.contentOffset.y) / 2.0)
        headerView.imageBottom?.constant = max(0, (scrollView.contentInset.top + scrollView.contentOffset.y) / 2.0)
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = (players?.count) ?? 0
        
        if(numRows == 0) {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
        return numRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellId, for: indexPath) as! PlayerTableViewCell

        cell.player = players?[indexPath.row]
        
        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //no-op: commit actions take place in UITableViewRowAction handlers
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "          ") {
            (action:UITableViewRowAction, indexPath:IndexPath) in
            
            self.performSegue(withIdentifier: Storyboard.editPlayerSegueId, sender: self.tableView.cellForRow(at: indexPath))
        }
        edit.backgroundColor = getColor(withLabelText: "\u{2710}", textColor: .white, bgColor: .lightGray, height: tableView.cellForRow(at: indexPath)!.bounds.height)

        
        return [edit]
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if editChukkarsTask != nil {
            editChukkarsTask?.resume()
            editChukkarsTask = nil
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if Storyboard.editPlayerSegueId == segue.identifier {
            let editVC = segue.destination as! EditPlayerViewController
            editVC.modalPresentationStyle = .popover
            editVC.popoverPresentationController?.delegate = self
            
            let playerCell = sender as! PlayerTableViewCell
            
            if let anchor = playerCell.numChukkarsLabel {
                editVC.popoverPresentationController?.sourceView = anchor
            }
            
            editVC.player = playerCell.player
            editVC.delegate = self
        }
    }
    
    
    // MARK: - EditPlayerViewControllerDelegate
    func onEditChukkarsRequested(task: URLSessionDataTask) {
        editChukkarsTask = task
        
        //control now goes to tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    }
}


extension SignupDayTableViewController {
    //MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
        }
    }
}


protocol SignupDayTableViewControllerDelegate: NSObjectProtocol {
    func refreshSignups()
    func segueToAddPlayer()
}
