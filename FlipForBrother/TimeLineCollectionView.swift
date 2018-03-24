//
//  TimeLineCollectionView.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

class TimeLineCollectionView: UICollectionView {
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPress.minimumPressDuration = 0.25
        addGestureRecognizer(longPress)
    }
    @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self)
        let editMenu = UIMenuController.shared
        becomeFirstResponder()
        let custom1Item = UIMenuItem(title: "Copy Key Frame", action: #selector(MainViewController.keyFrameCopy))
        let custom2Item = UIMenuItem(title: "Paste Key Frame", action: #selector(MainViewController.keyFramePaste))
        editMenu.menuItems = [custom1Item, custom2Item]
        editMenu.setTargetRect(CGRect(x: point.x, y: point.y, width: 20, height: 20), in: self.superview!)
        editMenu.setMenuVisible(true, animated: true)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}
