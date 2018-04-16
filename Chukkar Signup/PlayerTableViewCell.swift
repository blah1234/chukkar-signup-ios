//
//  PlayerTableViewCell.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/22/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var numChukkarsLabel: UILabel!
    

    var player: Player? {
        didSet {
            if let player = player {
                nameLabel.text = player.name
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
                dateFormatter.setLocalizedDateFormatFromTemplate("EEE, M/d h:mm a") // set template after setting locale
                
                requestedDateLabel.text = dateFormatter.string(from: player.createDate ?? Date())
                numChukkarsLabel.text = "\(player.numChukkars ?? 0)"
            } else {
                // maintain cell height for blank rows
                nameLabel.text = " "
                requestedDateLabel.text = " "
                numChukkarsLabel.text = " "
            }
        }
    }
    
    
    
}
