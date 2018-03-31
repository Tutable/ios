//
//  DateTimeUtility.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import Foundation

func getCurrentTimeStampValue() -> String
{
    return String(format: "%0.0f", Date().timeIntervalSince1970*1000)
}

func getTimestampFromDate(date : Date) -> Double
{
    return date.timeIntervalSince1970*1000
}

func getDateFromTimeStamp(_ timeStemp:Double) -> Date
{
    return Date(timeIntervalSince1970: TimeInterval(timeStemp/1000))
}

func getDateStringFromServerTimeStemp(_ timeStemp:Double) -> String{
    
    let date : Date = Date(timeIntervalSince1970: TimeInterval(timeStemp/1000))
    
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = DATE_FORMAT.DISPLAY_DATE_FORMAT
    return dateFormatter.string(from: date)
}
func getTimeStringFromServerTimeStemp(_ timeStemp:Double) -> String{
    
    let date : Date = Date(timeIntervalSince1970: TimeInterval(timeStemp/1000))
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    //dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = DATE_FORMAT.DISPLAY_TIME_FORMAT
    return dateFormatter.string(from: date)
}

func getDateTimeStringFromServerTimeStemp(_ timeStemp:Double) -> String{
    
    let date : Date = Date(timeIntervalSince1970: TimeInterval(timeStemp/1000))
    
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = DATE_FORMAT.DISPLAY_DATE_TIME_FORMAT
    return dateFormatter.string(from: date)
}


func getDateStringFromDate(date : Date) -> String
{
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = DATE_FORMAT.DISPLAY_DATE_FORMAT
    return dateFormatter.string(from: date)
}

func getDateFromDateString(strDate : String) -> Date
{
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = DATE_FORMAT.DISPLAY_DATE_FORMAT
    return dateFormatter.date(from: strDate)!
}

//MARK: Date difference
func getDifferenceFromCurrentTime(_ timeStemp : Double) -> Int
{
    let newDate : Date = Date(timeIntervalSince1970: TimeInterval(timeStemp/1000))
    let currentDate : Date = getCurrentDate()
    let interval = currentDate.timeIntervalSince(newDate)
    return Int(interval)
}

func getCurrentDate() -> Date
{
    let currentDate : Date = Date()
    return currentDate
}

func getDifferenceFromCurrentTimeInHourInDays(_ timestamp : Double) -> String
{
    let interval : Int = getDifferenceFromCurrentTime(timestamp)
    
    let second : Int = interval
    let minutes : Int = interval/60
    let hours : Int = interval/(60*60)
    let days : Int = interval/(60*60*24)
    let week : Int = interval/(60*60*24*7)
    let months : Int = interval/(60*60*24*30)
    let years : Int = interval/(60*60*24*30*12)
    
    var timeAgo : String = ""
    if  second < 60
    {
        timeAgo = (second < 3) ? "Just Now" : (String(second) + "s")
    }
    else if minutes < 60
    {
        timeAgo = String(minutes) + "m"
    }
    else if hours < 24
    {
        timeAgo = String(hours) + "h"
    }
    else if days < 30
    {
        timeAgo = String(days) + " "  + ((days > 1) ? "days" : "day")
    }
    else if week < 4
    {
        timeAgo = String(week) + " "  + ((week > 1) ? "weeks" : "week")
    }
    else if months < 12
    {
        timeAgo = String(months) + " "  + ((months > 1) ? "months" : "month")
    }
    else
    {
        timeAgo = String(years) + " "  + ((years > 1) ? "years" : "year")
    }
    
    if second > 3 {
        timeAgo = timeAgo + " ago"
    }
    return timeAgo
}

func isSameDate(firstDate : String, secondDate : String) -> Bool
{
    let strDate1 : String = getDateStringFromServerTimeStemp(Double(firstDate)!)
    let strDate2 : String = getDateStringFromServerTimeStemp(Double(secondDate)!)
    
    if strDate1 == strDate2
    {
        return true
    }
    return false
}

func getdayDifferenceFromCurrentDay(_ timeStemp : Double) -> String
{
    let calendar = NSCalendar.current
    let date1 = calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(timeStemp/1000)))
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    
    var timeAgo : String = ""
    if components.day == 0
    {
        timeAgo = "TODAY"
    }
    else if components.day == 1
    {
        timeAgo = "YESTERDAY"
    }
    else
    {
        timeAgo = getDateStringFromServerTimeStemp(TimeInterval(timeStemp))
    }
    
    return timeAgo
}

func getDateOnlyFromDate(date : Date) -> String
{
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "d"
    return dateFormatter.string(from: date)
}


func getOnlyDateTimestamp(date : Date) -> Double
{
    let strDate : String = getDateStringFromDate(date: date)
    return getTimestampFromDate(date: getDateFromDateString(strDate: strDate))
}

