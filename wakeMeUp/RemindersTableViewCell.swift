//
//  RemindersTableViewCell.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 4/11/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import QuartzCore


protocol RemindersTableViewCellDelegate {
    func reminderDeleted(id: Int)
    
    func completeReminder(id: Int)
}

class RemindersTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    var delegate: RemindersTableViewCellDelegate?
    var id: Int?
    var maxId: Int?
    
    var deleteView: UIView!
    var completeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        createView()
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func createView() {
        deleteView = UIView()
        completeView = UIView()
        deleteView.backgroundColor = UIColor.init(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
        completeView.backgroundColor = UIColor.init(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
        
    }
    
    func changeFrame() {
        let y = 370 + (90 * id!)
        let width = Int(self.superview!.frame.width / 2)
        completeView.frame = CGRect(x: 0, y: y, width: width, height: 90)
        deleteView.frame = CGRect(x: width, y: y, width: width, height: 90)
        self.completeView.alpha = 1.0
        self.deleteView.alpha = 1.0
    }
    
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            changeFrame()
            originalCenter = center
            self.superview!.addSubview(deleteView)
            self.superview!.addSubview(completeView)
            self.superview!.sendSubviewToBack(deleteView)
            self.superview!.sendSubviewToBack(completeView)
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
        }
        
        if recognizer.state == .Ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if deleteOnDragRelease {
                if delegate != nil && id != nil {
                    delegate!.reminderDeleted(id!)
                }
            } else if completeOnDragRelease {
                if delegate != nil && id != nil {
                    delegate!.completeReminder(id!)
                }
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = originalFrame
                })
            } else {
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = originalFrame
                })
            }
            
            UIView.animateWithDuration(0.3, animations: {
                self.completeView.alpha = 0.4
                self.deleteView.alpha = 0.4
            })
            
            self.completeView.removeFromSuperview()
            self.deleteView.removeFromSuperview()
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.maxId == self.id {
            return false
        }
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}




