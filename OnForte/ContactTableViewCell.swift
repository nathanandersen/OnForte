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

/**
 ContactTableViewCell depicts one contact in the ContactViewTable.
 Name on the left, and a check box on the right
 
 When selected, a popup is displayed to pick a phone number
 */
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

    /**
    Initialize the contact name label
    */
    private func initializeContactName() {
        contactNameLabel = Style.defaultLabel()
        contactNameLabel.textAlignment = .Natural
        self.addSubview(contactNameLabel)

    }
    /**
    Initialize the checkbox
     */
    private func initializeCheckBox() {
        checkBox = CheckboxButton()
        self.addSubview(checkBox)
        checkBox.userInteractionEnabled = false
    }
    /**
    Initialize constraints
    */
    private func initializeConstraints() {
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

    /**
    Load a contact into the cell
    */
    internal func loadContact(ic: InviteContact) {
        contactNameLabel.text = CNContactFormatter.stringFromContact(ic.contact, style: .FullName)
        checkBox.on = ic.isSelected
    }
}
