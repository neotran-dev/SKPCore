//
//  Date++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/20/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation

public extension Date {
    
    func toString(withFormat dateFormat: String, locale: Locale = Locale(identifier: "en_US"), timeZone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = locale
        if timeZone != nil { dateFormatter.timeZone = timeZone }
        return dateFormatter.string(from: self)
    }
    
    func timeIn24HourFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func startOfDay() -> Date {
        var components = Calendar.current.dateComponents([.year,.month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let result: Date = Calendar.current.date(from: components)!
        return result
    }
    
    func endOfDay() -> Date {
        var components = Calendar.current.dateComponents([.year,.month, .day, .hour, .minute, .second], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let result: Date = Calendar.current.date(from: components)!
        return result
    }
    
    func startOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.year,.month], from: self)
        components.day = 1
        let firstDateOfMonth: Date = Calendar.current.date(from: components)!
        return firstDateOfMonth
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func nextDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return nextDate ?? Date()
    }
    
    func previousDate() -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return previousDate ?? Date()
    }
    
    func addMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeYears(numberOfYears: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .year, value: -numberOfYears, to: self)
        return endDate ?? Date()
    }
    
    func getHumanReadableDayString() -> String {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        let calendar = Calendar.current.component(.weekday, from: self)
        return weekdays[calendar - 1]
    }
    
    func monthString() -> String {
        return self.toString(format: "MMM, YYYY")
    }
    
    
    func timeSinceDate(fromDate: Date) -> String {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self
        
        let components: DateComponents = Calendar.current.dateComponents([.minute,.hour,.day,.weekOfYear,.month,.year,.second], from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        
        if year >= 2{
            return "\(year) years ago"
        }else if (year >= 1){
            return "1 year ago"
        }else if (month >= 2) {
            return "\(month) months ago"
        }else if (month >= 1) {
            return "1 month ago"
        }else  if (week >= 2) {
            return "\(week) weeks ago"
        } else if (week >= 1){
            return "1 week ago"
        } else if (day >= 2) {
            return "\(day) days ago"
        } else if (day >= 1){
            return "1 day ago"
        } else if (hours >= 2) {
            return "\(hours) hours ago"
        } else if (hours >= 1){
            return "1 hour ago"
        } else if (minutes >= 2) {
            return "\(minutes) minutes ago"
        } else if (minutes >= 1){
            return "1 minute ago"
        } else if (seconds >= 3) {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
    static func daysBetween(fromDate: Date, toDate: Date) -> Int? {
        let calendar = Calendar.current
        let earliest = toDate < fromDate ? toDate  : fromDate
        let latest = (earliest == toDate) ? fromDate : toDate
        let date1 = calendar.startOfDay(for: earliest)
        let date2 = calendar.startOfDay(for: latest)
        return calendar.dateComponents([.day], from: date1, to: date2).day
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }

}
