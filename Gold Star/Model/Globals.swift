//
//  Globals.swift
//  Gold Star
//
//  Created by David Modro on 8/4/18.
//  Copyright © 2018 David Modro. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let GOLDSTAR_IMAGE  = #imageLiteral(resourceName: "goldstar")
let GREYSTAR_IMAGE = #imageLiteral(resourceName: "greystar")

let userCalendar = Calendar.current
let oneDayInterval = TimeInterval(60*60*24)

var summaryStarValues = Array(repeating: Bool(false), count: 7)
var summaryDays = userCalendar.veryShortWeekdaySymbols

func isDayAgo(dayAgo : Int, date: Date) -> Bool {
    //Evalurate whether a date is in a previous day
    //positive - days in past
    //0 - today
    //negative - days in future
    let otherDay = Date(timeIntervalSinceNow: -(TimeInterval(dayAgo) * oneDayInterval))
    let dateComponents = userCalendar.dateComponents([.year, .month, .day], from: otherDay)
    let isOnDay = userCalendar.date(date, matchesComponents: dateComponents)
    return isOnDay
}

func daysInStreak(habit:Habit) -> Int {
    var daysInStreak:Int = 0
    var isStreak = true
    var changed = false
//    var daysAgo : Int = 0
    if let dates = habit.starDates {
        repeat {
            for date in dates {
                if isDayAgo(dayAgo: daysInStreak, date: date) {
                    changed = true
                }
            }
            if changed {
                daysInStreak += 1
                changed = false
            } else {
                isStreak = false
            }
        } while isStreak
    }
    return daysInStreak
}

func createStreakLabel(habit: Habit) -> String {
    var streakText = ""
    let days = daysInStreak(habit: habit)
    if days > 0 {
        streakText = "\(days) day streak!"
    }
    return streakText
}

func starWasEarned(habit: Habit?, day: Int) -> (Bool, Int?) {
    if let starDates = habit?.starDates, starDates.count>0 {
        for index in stride(from: starDates.count-1, through: 0, by: -1) {
            if isDayAgo(dayAgo: day, date: starDates[index]) {
                return (true, index)
            }
        }
    }
    return (false, nil)
}

func starEarned(starDates: [Date]?, day: Int) -> (Bool, Int?) {
    if let dates = starDates {
        for index in stride(from: dates.count-1, through: 0, by: -1) {
            if isDayAgo(dayAgo: day, date: dates[index]) {
                return (true, index)
            }
        }
    }
    return (false, nil)
}

