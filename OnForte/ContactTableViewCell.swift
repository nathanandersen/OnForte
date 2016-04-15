//
//  ContactTableViewCell.swift
//  Forte
//
//  Created by Nathan Andersen on 4/11/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class ContactTableViewCell: UITableViewCell {

    var contactNameLabel: UILabel!
    var checkBox: CheckboxButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeContactName()
        initializeCheckBox()
        initializeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("ContactTableViewCell does not support NSCoding")
    }

    func initializeContactName() {
        contactNameLabel = Style.defaultLabel()
        contactNameLabel.textAlignment = .Natural
        self.addSubview(contactNameLabel)

    }

    func initializeCheckBox() {
        checkBox = CheckboxButton()
        self.addSubview(checkBox)
        checkBox.userInteractionEnabled = false
    }

    func initializeConstraints() {
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        contactNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: checkBox,
                           attribute: .CenterY,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .CenterY,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: checkBox,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: checkBox,
                           attribute: .Height,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: checkBox,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 35).active = true
        NSLayoutConstraint(item: checkBox,
                           attribute: .Right,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .Right,
                           multiplier: 1,
                           constant: -10).active = true
        NSLayoutConstraint(item: contactNameLabel,
                           attribute: .CenterY,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .CenterY,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: checkBox,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: contactNameLabel,
                           attribute: .Right,
                           multiplier: 1,
                           constant: 15).active = true
        NSLayoutConstraint(item: contactNameLabel,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 10).active = true

        checkBox.updateConstraints()
        contactNameLabel.updateConstraints()
    }

    func loadContact(ic: InviteContact) {
        contactNameLabel.text = CNContactFormatter.stringFromContact(ic.contact, style: .FullName)
        checkBox.on = ic.isSelected
//        self.selected = ic.isSelected
    }
/*
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/


    
}
