//
//  Constants.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/13/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

struct Constants {
    
    struct MainViewController {
        static let RESET_DATE_KEY = "RESET_DATE_KEY"
        static let ACTIVE_DAYS_KEY = "ACTIVE_DAYS_KEY"
        static let CONTENT_KEY = "CONTENT_KEY"
        static let LAST_MODIFIED_KEY = "LAST_MODIFIED_KEY"
        
        static let BASE_URL = "http://centralvalleypolo.appspot.com"
        static let ACTIVE_DAYS_URL = BASE_URL + "/signup/json/getActiveDays"
        static let GET_PLAYERS_URL = BASE_URL + "/signup/json/getAllPlayers"
        
        static let SIGNUP_CLOSED = "!!!SIGNUP_CLOSED!!!"
    }
    
    struct SignupDayViewController {
        static let BANNER_IMAGE_COUNT = 13
    }
    
    struct AddPlayerVeiwController {
        static let ADD_PLAYER_URL = MainViewController.BASE_URL + "/signup/json/addPlayer"
        static let PLAYER_NUMCHUKKARS_FIELD = "_numChukkars"
        static let PLAYER_NAME_FIELD = "_name"
        static let PLAYER_REQUESTDAY_FIELD = "_requestDay"
    }
}
