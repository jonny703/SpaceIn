//
//  Global.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import CoreLocation


var currentUserLocation = CLLocation()

struct Global {
    static var currentUserLocation = CLLocation()
    static var currentCenterLocation = CLLocation()
    static var isLogIn = false
    static var currentUser = SpaceUser()
    static var currentDistance: Double = 4000.0
    static var pushToken = String()
}


func getDistance(firstLocation: CLLocation, secondLocation: CLLocation) -> Bool {
    
    var isOver = false
    
    let radius = firstLocation.distance(from: secondLocation)
    
    if radius / 1000 > Global.currentDistance / 10 {
        isOver = true
    }
    
    return isOver
}

func returnLeftTimedateformatter(date: Double) -> String {
    
    let date1:Date = Date() // Same you did before with timeNow variable
    let date2: Date = Date(timeIntervalSince1970: date)
    
    let calender:Calendar = Calendar.current
    let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date1, to: date2)
    print(components)
    var returnString:String = ""
    print(abs(components.second!))
    
    if abs(components.year!) >= 1 {
        returnString = String(describing: abs(components.year!))+" y"
    } else if abs(components.month!) >= 1{
        returnString = String(describing: abs(components.month!))+" m"
    } else if abs(components.day!) >= 1{
        returnString = String(describing: abs(components.day!)) + " d"
    } else if abs(components.hour!) >= 1{
        returnString = String(describing: abs(components.hour!)) + " h"
    } else if abs(components.minute!) >= 1{
        returnString = String(describing: abs(components.minute!)) + " min"
    } else if components.second! < 60 {
        returnString = "Just Now"
    }
    return returnString
}

func returnDayWithDateformatter(date: Double) -> Int {
    
    let date1:Date = Date() // Same you did before with timeNow variable
    let date2: Date = Date(timeIntervalSince1970: date)
    
    let calender:Calendar = Calendar.current
    let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date1, to: date2)
//    print(components)
    var returnNum: Int = 0
//    print(components.second)
    
    if abs(components.day!) >= 1{
        returnNum = abs(components.day!)
    } else if components.hour! >= 1{
        returnNum = 1
    } else if components.minute! >= 1{
        returnNum = 1
    } else if components.second! < 60 {
        returnNum = 1
    }
    return returnNum
}

















