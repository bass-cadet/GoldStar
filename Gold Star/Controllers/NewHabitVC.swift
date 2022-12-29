//
//  NewHabitVC.swift
//  Gold Star
//
//  Created by David Modro on 8/3/18.
//  Copyright © 2018 David Modro. All rights reserved.
//

import UIKit
import os.log

class NewHabitVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var habitReturn : Habit?
    var isNewHabit : Bool?
    var isTextField : Bool?
    var starDates : [Date]?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var habitName: UITextField!
    @IBOutlet weak var habitDetail: UITextView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var summaryDays: [UILabel]!
    @IBOutlet var starButtons: [UIButton]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateSummaryData()
        reloadSummary()

        starDates = habitReturn?.starDates
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        habitName.delegate = self
        habitDetail.delegate = self
//        scrollView.delegate = self
        
        habitName.text = habitReturn?.title
        habitDetail.text = habitReturn?.detail
        habitDetail.layer.borderWidth = 1
        habitDetail.layer.borderColor = UIColor.gray.cgColor
        if let habit = habitReturn {
            streakLabel.text = createStreakLabel(habit: habit)
            loadStars(habit: habit)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else { //This line checks that the sender is a button and that the button is the saveAlarm button
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        // Set the habit to be passed to AlarmsTableViewController after the unwind segue.
        habitReturn?.title = habitName.text
        habitReturn?.detail = habitDetail.text
        habitReturn?.starDates = starDates
        if habitReturn?.addedDate == nil {
            habitReturn?.addedDate = Date()
        }
    }
    
    //Star update -------------------------------------------
    @IBAction func changeStar(_ sender: Any) {
        let button = sender as! UIButton
        let day = button.tag
        let starsEarned = starEarned(starDates: starDates, day: day)
        if starsEarned.0 { //if true, then starDate and index must exist and count must be >0
            button.setBackgroundImage(GREYSTAR_IMAGE, for: .normal)
            starDates?.remove(at: starsEarned.1!)
        } else {
            button.setBackgroundImage(GOLDSTAR_IMAGE, for: .normal)
            if starDates == nil {
                starDates = [Date().addingTimeInterval(TimeInterval(-day*60*60*24))]
            } else {
                starDates?.append(Date().addingTimeInterval(TimeInterval(-day*60*60*24)))
                starDates?.sort()
            }
        }
    }
    
    //Text field and keyboard control -------------------------------------
    @IBAction func editedHabitName(_ sender: Any) {
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect  else { return }
        if isTextField ?? false {  //Text field, not text view
            scrollView.contentInset.bottom = view.convert(keyboardFrame, from: nil).size.height
        } else {
           //scrollView.contentInset.bottom = view.convert(keyboardFrame, from: nil).size.height //no scroll at all

//            scrollView.contentInset.bottom = view.convert(habitDetail.frame, from:nil).origin.y - view.convert(keyboardFrame, from:nil).origin.y //no scroll at all
            
//            scrollView.setContentOffset(CGPoint(x: 0, y: view.convert(keyboardFrame, from: nil).size.height), animated: true) //scrolls, but not always the correct amount
            
            let fieldOrigin = view.convert(habitDetail.frame, from: nil).origin.y //FIX: Thinks this is only 28.
            let fieldHeight = habitDetail.frame.height
//            let fieldFrame = view.convert(habitDetail.frame, from: nil)
            let keyboardOrigin = view.convert(keyboardFrame, from: nil).origin.y
//            print("scrollview content size : \(scrollView.contentSize)")
//            print(fieldOrigin, fieldHeight, keyboardOrigin)
            if fieldOrigin + fieldHeight > keyboardOrigin {
               scrollView.contentInset.bottom = view.convert(keyboardFrame, from: nil).size.height
                //scrollView.setContentOffset(CGPoint(x: 0, y: fieldOrigin), animated: true)
            }
            
//            print("trying to scroll a textview")
//            print("textview origin: \(fieldOrigin)")
//            print("textview height: \(habitDetail.frame.height)")
//            print("keyboard origin: \(keyboardFrame.origin)")
//            if (habitDetail.superview!.frame.origin.y + habitDetail.frame.height) > keyboardFrame.origin.y {
//                let scrollPoint : CGPoint = CGPoint.init(x:0, y:habitDetail.superview!.superview!.frame.origin.y + habitDetail.frame.height - keyboardFrame.origin.y)
//                scrollView.setContentOffset(scrollPoint, animated: true)
//            }
//            let scrollPoint : CGPoint = CGPoint.init(x:0, y:habitDetail.frame.origin.y)
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollPoint), animated: true)
//            var aRect : CGRect = self.view.frame //frame of current view
//            aRect.size.height -= keyboardFrame.height //frame visible after keyboard shows
//            if (!aRect.contains(habitDetail!.frame.origin)) {
//                self.scrollView.setContentOffset(CGPoint(x:0, y:self.habitDetail!.frame.origin.y+20), animated: true)
//            }
//            scrollView.scrollRectToVisible(self.habitDetail.superview!.frame, animated: true)
//            scrollView.scrollRectToVisible(self.habitDetail.superview?.frame ?? habitDetail.frame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0 //for textField
//        scrollView.setContentOffset(CGPoint.zero, animated: true) //for textView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextField = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextField = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        
//    }

    //View Setup ----------------------------------------
    func loadStars(habit: Habit) {
        //stars
        for img in starButtons {
            if starWasEarned(habit: habit, day: img.tag).0 {
                img.setBackgroundImage(GOLDSTAR_IMAGE, for: .normal)
            } else {
                img.setBackgroundImage(GREYSTAR_IMAGE, for: .normal)
            }
            img.setTitleColor(UIColor.clear, for: .normal)
        }
    }
    
    func reloadSummary() {
        let dayNames = userCalendar.veryShortWeekdaySymbols
        let today = userCalendar.dateComponents([.weekday], from: Date()).weekday
        
        //Update Stars
        var day = 0 //today
        var index = 0
        for star in starButtons {
            if summaryStarValues[day] {
                star.setBackgroundImage(GOLDSTAR_IMAGE, for: .normal)
            } else {
                star.setBackgroundImage(GREYSTAR_IMAGE, for: .normal)
            }
            day += 1
        }
        
        //Update Days of week
        for daySymbol in summaryDays {
            index = today! - 1 - daySymbol.tag
            if index<0 {
                index = index+7
            }
            if index >= 0, index <= 6 {
                daySymbol.text = dayNames[index]
            }
        }

//        day = 0
//        for daySymbol in summaryDays {
//            index = today!-1-day
//            if index<0 {
//                index = index+7
//            }
//            daySymbol.text = dayNames[index]
//            day += 1
//        }
    }
    
    func updateSummaryData() -> Void {
        var starEarnedOnDay = true
        for day in 0 ... summaryStarValues.count-1 {
            if !starWasEarned(habit: habitReturn, day: day).0 {
                starEarnedOnDay = false
                break
            }
            summaryStarValues[day] = starEarnedOnDay
            starEarnedOnDay = true
        }
    }

}
