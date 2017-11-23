//
//  Constants.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/13/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

struct Constants {
    
    struct SignupDayTableViewController {
        static let BANNER_IMAGE_COUNT = 13
    }
    
    struct MainViewController {
        static let BASE_URL = "http://centralvalleypolo.appspot.com"
        static let ACTIVE_DAYS_URL = BASE_URL + "/signup/json/getActiveDays"
        static let GET_PLAYERS_URL = BASE_URL + "/signup/json/getAllPlayers"
    }
    
    struct Data {
        static let RESET_DATE_KEY = "RESET_DATE_KEY"
        static let ACTIVE_DAYS_KEY = "ACTIVE_DAYS_KEY"
        static let CONTENT_KEY = "CONTENT_KEY"
        static let LAST_MODIFIED_KEY = "LAST_MODIFIED_KEY"
        
        static let SIGNUP_CLOSED = "!!!SIGNUP_CLOSED!!!"
    }
    
    struct Player {
        static let PLAYERS_LIST_FIELD = "_playersList"
        
        static let ID_FIELD = "_id"
        static let NAME_FIELD = "_name"
        static let REQUESTDAY_FIELD = "_requestDay"
        static let NUMCHUKKARS_FIELD = "_numChukkars"
        static let CREATEDATE_FIELD = "_createDate"
    }
    
    struct AddPlayerVeiwController {
        static let ADD_PLAYER_URL = MainViewController.BASE_URL + "/signup/json/addPlayer"
    }
    
    struct EditPlayerViewController {
        static let EDIT_PLAYER_URL = MainViewController.BASE_URL + "/signup/json/editChukkars"
        static let EDIT_PLAYER_CHUKKARS_SUCCESS_KEY = "com.defenestrate.chukkars.ios.editPLayerChukkarsSuccess"
    }
}
