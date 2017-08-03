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
        case .MONDAY: return "MONDAY"
        case .TUESDAY: return "TUESDAY"
        case .WEDNESDAY: return "WEDNESDAY"
        case .THURSDAY: return "THURSDAY"
        case .FRIDAY: return "FRIDAY"
        case .SATURDAY: return "SATURDAY"
        case .SUNDAY: return "SUNDAY"
        }
    }
    
    public static func valueOf(name: String) -> Day {
        switch name.lowercased() {
        case "monday":
            return .MONDAY
        case "tuesday":
            return .TUESDAY
        case "wednesday":
            return .WEDNESDAY
        case "thursday":
            return .THURSDAY
        case "friday":
            return .FRIDAY
        case "saturday":
            return .SATURDAY
        case "sunday":
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
