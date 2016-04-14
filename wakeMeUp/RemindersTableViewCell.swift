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
}

class RemindersTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var delegate: RemindersTableViewCellDelegate?
    var id: Int?
    var maxId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            originalCenter = center
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
        }
        
        if recognizer.state == .Ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if deleteOnDragRelease {
                if delegate != nil && id != nil {
                    delegate!.reminderDeleted(id!)
                }
            } else {
                UIView.animateWithDuration(0.2, animations: {
                    self.frame = originalFrame
                })
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.maxId > 0 else {
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




