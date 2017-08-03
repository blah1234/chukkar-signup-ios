//
//  Player.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/21/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

struct Player {
    var createDate: Date? = nil
    var id: String? = nil
    var name: String? = nil
    var numChukkars: Int? = nil
    var requestDay: Day? = nil
    
    init(createDate: Date, id: String, name: String, numChukkars: Int, requestDay: Day) {
        self.createDate = createDate
        self.id = id
        self.name = name
        self.numChukkars = numChukkars
        self.requestDay = requestDay
    }
}
