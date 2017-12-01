//
//  Day.swift
//  Chukkar Signup
//
//  Created by Shawn Hwang on 6/21/17.
//  Copyright © 2017 Bay Area Polo Clubs. All rights reserved.
//

import Foundation

enum Day: Int, Comparable, CustomStringConvertible {
    case MONDAY = 1
    case TUESDAY
    case WEDNESDAY
    case THURSDAY
    case FRIDAY
    case SATURDAY
    case SUNDAY
    
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .MONDAY: return NSLocalizedString("day-mon", comment: "day enum string value").uppercased()
        case .TUESDAY: return NSLocalizedString("day-tues", comment: "day enum string value").uppercased()
        case .WEDNESDAY: return NSLocalizedString("day-wed", comment: "day enum string value").uppercased()
        case .THURSDAY: return NSLocalizedString("day-thurs", comment: "day enum string value").uppercased()
        case .FRIDAY: return NSLocalizedString("day-fri", comment: "day enum string value").uppercased()
        case .SATURDAY: return NSLocalizedString("day-sat", comment: "day enum string value").uppercased()
        case .SUNDAY: return NSLocalizedString("day-sun", comment: "day enum string value").uppercased()
        }
    }
    
    var icon : UIImage {
        switch self {
        case .MONDAY: return #imageLiteral(resourceName: "tab-mon")
        case .TUESDAY: return #imageLiteral(resourceName: "tab-tues")
        case .WEDNESDAY: return #imageLiteral(resourceName: "tab-wed")
        case .THURSDAY: return #imageLiteral(resourceName: "tab-thurs")
        case .FRIDAY: return #imageLiteral(resourceName: "tab-fri")
        case .SATURDAY: return #imageLiteral(resourceName: "tab-sat")
        case .SUNDAY: return #imageLiteral(resourceName: "tab-sun")
        }
    }
    
    public static func valueOf(name: String) -> Day {
        switch name.lowercased() {
        case NSLocalizedString("day-mon", comment: "day enum string value").lowercased():
            return .MONDAY
        case NSLocalizedString("day-tues", comment: "day enum string value").lowercased():
            return .TUESDAY
        case NSLocalizedString("day-wed", comment: "day enum string value").lowercased():
            return .WEDNESDAY
        case NSLocalizedString("day-thurs", comment: "day enum string value").lowercased():
            return .THURSDAY
        case NSLocalizedString("day-fri", comment: "day enum string value").lowercased():
            return .FRIDAY
        case NSLocalizedString("day-sat", comment: "day enum string value").lowercased():
            return .SATURDAY
        case NSLocalizedString("day-sun", comment: "day enum string value").lowercased():
            return .SUNDAY
        default:
            fatalError("unrecognized name: \(name)")
        }
    }
    
    // MARK - Comparable
    public static func < (a: Day, b: Day) -> Bool {
        return a.rawValue < b.rawValue
    }
}
