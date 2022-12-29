//
//  HabitTableViewCell.swift
//  Gold Star
//
//  Created by David Modro on 8/4/18.
//  Copyright © 2018 David Modro. All rights reserved.
//

import UIKit

//protocol ButtonTappedDelegate {
//    func starTapped(at indexPath:IndexPath)
//}

class HabitTableViewCell: UITableViewCell {
    @IBOutlet weak var habitTitle: UILabel!
    //@IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet var habitImages: [UIImageView]!
    
    var tapAction: ((UITableViewCell) -> Void)?
    
    //    var delegate:ButtonTappedDelegate!
    //    var indexPath : IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func completed(_ sender: Any) {
        //Check summary and update
        //Change button image
        let image = GOLDSTAR_IMAGE
        //completedButton.setImage(image, for: .normal)
        completeButton.setBackgroundImage(image, for: .normal)
        completeButton.setTitleColor(UIColor.clear, for: .normal)
        
        //Update habit
        tapAction?(self)
        
        //Disable button, maybe. Or add logic to undo the habit completion
    }
//    @IBAction func completed(_ sender: Any) {
//        //Check summary and update
//        //Change button image
//        let image = GOLDSTAR_IMAGE
//        //completedButton.setImage(image, for: .normal)
//        completeButton.setBackgroundImage(image, for: .normal)
//        completeButton.setTitleColor(UIColor.clear, for: .normal)
//        
//        //Update habit
//        tapAction?(self)
//        
//        //Disable button, maybe. Or add logic to undo the habit completion
//    }
    
    func configureCell(habit: Habit) {
        habitTitle.text = habit.title
        streakLabel.text = createStreakLabel(habit: habit)
        
        //Completed today star
        if starWasEarned(habit: habit, day: 0).0 {
            let image = GOLDSTAR_IMAGE
            completeButton.setBackgroundImage(image, for: .normal)
            completeButton.setTitleColor(UIColor.clear, for: .normal)
            
        } else {
            let image = GREYSTAR_IMAGE
            completeButton.setBackgroundImage(image, for: .normal)
            completeButton.setTitleColor(UIColor.clear, for: .normal)
            
        }
        
        //stars
        for img in habitImages {
            if starWasEarned(habit: habit, day: img.tag).0 {
                img.image = GOLDSTAR_IMAGE
            } else {
                img.image = GREYSTAR_IMAGE
            }
        }
    }
    
}
