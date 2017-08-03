//
//  Utils.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/23/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

class Utils {
    
    //generate a random Int value between the given minimum and maximum
    static func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
