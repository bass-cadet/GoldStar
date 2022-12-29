//
//  Habits_Table_VCTableViewController.swift
//  Gold Star
//
//  Created by David Modro on 8/3/18.
//  Copyright © 2018 David Modro. All rights reserved.
//

import UIKit
import CoreData
import os.log

class Habits_Table_VC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController : NSFetchedResultsController<Habit>!
    
    @IBOutlet var summaryDays: [UILabel]!
    @IBOutlet var summaryStars: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
//        controller.delegate? = self
        
        //Generate test data
        //generateTestData()
        attemptFetch()
        
        updateSummaryData()
        reloadSummary()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter", size: 20)!]
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Habits_Table_VC.addHabit))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "habitCell", for: indexPath) as? HabitTableViewCell {
            // Configure the cell...
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func configureCell(cell:HabitTableViewCell, indexPath: IndexPath) {
        let habit = fetchedResultsController.object(at: indexPath)
        cell.configureCell(habit: habit)
//        print("cell configured")
//        print(indexPath)
        cell.tapAction = {
            cell in
//            print("star tapped")
//            print(indexPath)
            if let lastStarDate = habit.starDates?.last, isDayAgo(dayAgo: 0, date: lastStarDate) {
//            if let lastStarDate = self.fetchedResultsController.object(at: indexPath).starDates?.last, isDayAgo(dayAgo: 0, date: lastStarDate) {
                //Star already claimed today
                print("Star already claimed today")
            } else {
                //Claim star today
                if habit.starDates == nil {
                    habit.starDates = [Date()]
                } else {
                    habit.starDates?.append(Date())
                }
//                if self.fetchedResultsController.object(at: indexPath).starDates == nil {
//                    self.fetchedResultsController.object(at: indexPath).starDates = [Date()]
//                } else {
//                    self.fetchedResultsController.object(at: indexPath).starDates?.append(Date())
//                }
                self.saveData()
                self.updateSummaryData()
                self.reloadSummary()
                self.tableView.reloadData()
            }
        }
    }
    
    // Override to support conditional editing of the table view.
    //    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        // Return false if you do not want the specified item to be editable.
    //    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let habit = fetchedResultsController.object(at: indexPath)
            context.delete(habit)
            saveData()
            //            tableView.deleteRows(at: [indexPath], with: .fade)
            //            print("table updated")
            updateSummaryData()
            reloadSummary()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "addHabit" {
            let destination = segue.destination as? UINavigationController
            let destinationVC = destination?.topViewController as? NewHabitVC
            let habit = Habit(context: context)
            destinationVC?.habitReturn = habit
            destinationVC?.isNewHabit = true
        } else if segue.identifier == "editHabit" {
            let destinationVC = segue.destination as? NewHabitVC
            destinationVC?.isNewHabit = false
            if let indexPath = tableView.indexPathForSelectedRow {
                let habit = fetchedResultsController.object(at: indexPath)
                destinationVC?.habitReturn = habit
            }
        } else {
            
        }
        // Pass the selected object to the new view controller.
    }
    
    @objc func addHabit() {
        performSegue(withIdentifier: "addHabit", sender: nil)
    }
    
    @IBAction func unwindCancel(sender: UIStoryboardSegue){
        //Cancelled new or edit habit
        
        //Check for a new habit that was cancelled
        if let sourceViewController = sender.source as? NewHabitVC, let habit = sourceViewController.habitReturn {
            if let newHabit = sourceViewController.isNewHabit, newHabit {
//                print(newHabit)
                //Delete the added habit
                context.delete(habit)
                saveData()
                tableView.reloadData()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindSave(sender: UIStoryboardSegue){
        //Save data and dismiss
        if let sourceViewController = sender.source as? NewHabitVC, let habit = sourceViewController.habitReturn {
            //Save data to existing record if edited
            if sourceViewController.isNewHabit == false {
                if let indexPath = tableView.indexPathForSelectedRow {
                    //  if let databaseIndexPath = databaseFromTable(tableIndexPath: indexPath) {
                    let editedHabit = fetchedResultsController.object(at: indexPath)
                    editedHabit.title = habit.title
                    editedHabit.detail = habit.detail
                    //  }
                }
            }
            //If new, add to habits
            if sourceViewController.isNewHabit == true {
                attemptFetch()
            }
        }
        saveData()
        tableView.reloadData()
        updateSummaryData()
        reloadSummary()
        dismiss(animated: true, completion: nil)
    }
    
    func attemptFetch() {
        let fetchRequest : NSFetchRequest<Habit> = Habit.fetchRequest()
        let dateSort = NSSortDescriptor(key: "addedDate", ascending : false)
        fetchRequest.sortDescriptors = [dateSort]
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchController.delegate = self
        self.fetchedResultsController = fetchController
        do {
            try fetchController.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
//        print("fetched")
//        printStuff()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSummaryData()
        reloadSummary()
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //Data changed, update table
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
//                print("deleted tableview rows")
//                printStuff()
            }
            break
        case .move:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! HabitTableViewCell
                configureCell(cell: cell, indexPath: indexPath)
            }
        @unknown default:
            break
        }
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        //Data changed, update table
//        switch type {
//        case .insert:
//            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
//            }
//            break
//        case .delete:
//            if let indexPath = indexPath {
//                print("controller noticed a deletion")
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            break
//        case .move:
//            if let indexPath = newIndexPath {
//                tableView.insertRows(at: [indexPath], with: .fade)
//            }
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            break
//        case .update:
//            if let indexPath = indexPath {
//                let cell = tableView.cellForRow(at: indexPath) as! HabitTableViewCell
//                configureCell(cell: cell, indexPath: indexPath)
//            }
//        }
//    }
    
    func saveData() {
        do {
            try context.save()
            attemptFetch()
        } catch {
            print("Failed to save context")
        }
    }
    
    func reloadSummary() {
        let dayNames = userCalendar.veryShortWeekdaySymbols
        let today = userCalendar.dateComponents([.weekday], from: Date()).weekday
        
        //Update Stars
        var day = 0 //today
        var index = 0
        for star in summaryStars {
            if summaryStarValues[day] {
                star.image = GOLDSTAR_IMAGE
            } else {
                star.image = GREYSTAR_IMAGE
            }
            day += 1
        }
        
        //Update Days of week
        day = 0
        for daySymbol in summaryDays {
            index = today!-1-day
            if index<0 {
                index = index+7
            }
            daySymbol.text = dayNames[index]
            day += 1
        }
    }
    
    func updateSummaryData() -> Void {
        var starEarnedOnDay = true
        if let objects = fetchedResultsController.fetchedObjects {
            for day in 0 ... summaryStarValues.count-1 {
                
                for object in objects {
                    if !starWasEarned(habit: object, day: day).0 {
                        starEarnedOnDay = false
                        break
                    }
                }
                summaryStarValues[day] = starEarnedOnDay
                starEarnedOnDay = true
            }
        }
    }
        
    func generateTestData(){
        let habit0 = Habit(context: context)
        habit0.addedDate = Date()
        habit0.starDates = [Date().addingTimeInterval(-2*oneDayInterval)]
        habit0.title = "Program every day"
        habit0.detail = "Do it. Do it. Do it"
        let habit1 = Habit(context: context)
        habit1.addedDate = Date()-80000
        habit1.starDates = [Date().addingTimeInterval(-2*oneDayInterval), Date().addingTimeInterval(-oneDayInterval), Date()]
        habit1.title = "Brush teeth"
        habit1.detail = "Or floss, whatever"
        
        saveData()
    }
    
    func printStuff() {
        print("number of habits in the fetch results controller: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        print("number of cells in table: \(tableView.numberOfRows(inSection: 0))")
    }
    
}




