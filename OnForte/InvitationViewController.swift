//
//  InvitationController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/11/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI
import Alamofire

/**
 The InvitationViewController displays a list of contacts to choose and invite to the playlist.
 */

class InvitationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate {

    var contacts = [InviteContact]()
    var filteredContacts = [InviteContact]()
    var tableView: UITableView!
    let searchController = CustomSearchController(searchResultsController: nil)
    var bottomBar: UIToolbar!
    var parent: UIViewController!
    var selectedContacts = [CNContact]()

    var selectedPhoneNumbers = [CNPhoneNumber]()

    func setParentVC(parent: UIViewController) {
        self.parent = parent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Style.whiteColor
        renderTableView()
        renderSearchBar()
        renderBottomBar()
        renderBottomBarContents()
        addConstraints()
        definesPresentationContext = true



        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.contacts = self.findContacts()
            self.filteredContacts = self.contacts

            dispatch_async(dispatch_get_main_queue()) {
                self.tableView!.reloadData()
                self.presentViewController(self.searchController, animated: true, completion: nil)
            }
        }
    }

    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }

    /**
     Render the search bar
    */
    private func renderSearchBar() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Selected"]
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
    }

    /**
    Add constraints.
     */
    private func addConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomBar, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomBar, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0).active = true

        NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomBar, attribute: .Top, multiplier: 1, constant: 0).active = true

        tableView.updateConstraints()
        bottomBar.updateConstraints()
    }

    /**
    Render the bottom bar
     */
    private func renderBottomBar() {
        bottomBar = UIToolbar()
        self.view.addSubview(bottomBar)
    }

    /**
    Render the contents of the bottom bar
    */
    private func renderBottomBarContents() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(InvitationViewController.cancel))
        cancelButton.tintColor = Style.redColor
        if !selectedContacts.isEmpty {
            let sendButton = UIBarButtonItem(title: "Send", style: .Done, target: self, action: #selector(InvitationViewController.sendInvitations))
            bottomBar.setItems([cancelButton,flexibleSpace,sendButton], animated: true)
            return
        }
        bottomBar.setItems([flexibleSpace,cancelButton,flexibleSpace], animated: true)
    }

    /**
     Send the invitations using Twilio
    */
    internal func sendInvitations() {
        let twilioPhoneNumber = keys!["TwilioPhoneNumber"] as! String
        let twilioUsername = keys!["TwilioAccountSID"] as! String
        let twilioPassword = keys!["TwilioAuthToken"] as! String

        for number in selectedPhoneNumbers {
            let digits = number.stringValue
            let message = [
                "To": digits,
                "From" : twilioPhoneNumber,
                "Body" : "You've been invited to join a playlist on Forte at Forte://" + PlaylistHandler.playlistId + ". Don't have the app? Join the fun at www.onforte.com/" + PlaylistHandler.playlistId + " ."
            ]
             Alamofire.request(.POST, "https://\(twilioUsername):\(twilioPassword)@api.twilio.com/2010-04-01/Accounts/\(twilioUsername)/Messages", parameters: message).responseJSON { response in
                print("sent")
            }
        }
        self.parent.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     Cancel the invitatation
    */
    internal func cancel() {
        self.parent.dismissViewControllerAnimated(true, completion: nil)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setNeedsLayout()
    }

    /** 
    Filter table contents
    */
    internal func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredContacts = contacts.filter { contact in
            let categoryMatch = (scope == "All") || (contact.isSelected == (scope == "Selected"))
            if searchText == "" {
                return categoryMatch
            } else {
                return  categoryMatch && contact.fullName()!.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        tableView.reloadData()
    }

    /**
     Render the table view
    */
    private func renderTableView() {
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.keyboardDismissMode = .OnDrag
        tableView.allowsMultipleSelection = true
        tableView.registerClass(ContactTableViewCell.self, forCellReuseIdentifier: "ContactTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    /**
     Find all contacts
    */
    private func findContacts() -> [InviteContact] {
        let store = CNContactStore()

        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                           CNContactPhoneNumbersKey]

        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

        var contacts = [InviteContact]()

        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                contacts.append(InviteContact(contact: contact))
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        return contacts
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && (searchController.searchBar.text != "" || searchController.searchBar.selectedScopeButtonIndex == 1) {
            return filteredContacts.count
        }
        return contacts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
        let contact: InviteContact
        if searchController.active && (searchController.searchBar.text != "" || searchController.searchBar.selectedScopeButtonIndex == 1) {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        cell.selectionStyle = .None
        cell.loadContact(contact)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: UIViewController!
        if searchController.active {
            vc = searchController
        } else {
            vc = self
        }

        searchController.searchBar.resignFirstResponder()
        let ic: InviteContact
        if searchController.active && (searchController.searchBar.text != "" || searchController.searchBar.selectedScopeButtonIndex == 1) {
            ic = filteredContacts[indexPath.row]
        } else {
            ic = contacts[indexPath.row]
        }
        if ic.isSelected {
            let index: Int = selectedContacts.indexOf(ic.contact)!
            selectedContacts.removeAtIndex(index)
            selectedPhoneNumbers.removeAtIndex(index)
            ic.isSelected = false
            self.tableView.reloadData()
            self.renderBottomBarContents()
        } else {
            if (ic.contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                let alertController = UIAlertController(title: ic.fullName(), message: "Please select a number", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    print(action)
                }
                alertController.addAction(cancelAction)

                for phoneNumber:CNLabeledValue in ic.contact.phoneNumbers {
                    let a = phoneNumber.value as! CNPhoneNumber
                    var label = phoneNumber.label
                    let garbageLength = 4
                    if label.substringToIndex(label.startIndex.advancedBy(4)) == "_$!<" {
                        let range: Range<String.Index> = label.startIndex.advancedBy(garbageLength)..<label.endIndex.advancedBy(-1*garbageLength)
                        label = label.substringWithRange(range)
                    }
                    let option = UIAlertAction(title: label + ": " + a.stringValue, style: .Default, handler: {(action) in
                        ic.isSelected = true
                        self.selectedContacts.append(ic.contact)
                        self.selectedPhoneNumbers.append(a)
                        self.tableView.reloadData()
                        self.renderBottomBarContents()
                    })
                    alertController.addAction(option)
                }
                vc.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: ic.fullName(), message: "There are no phone numbers for this contact.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    print(action)
                }
                alertController.addAction(cancelAction)
                vc.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

/**
 A custom search bar, that does not display a cancel button
 */
class CustomSearchBar: UISearchBar {
    override func setShowsCancelButton(showsCancelButton: Bool, animated: Bool) {
        // do nothing
    }
}

/**
 A custom search controller that implements the custom search bar
 */
class CustomSearchController: UISearchController {

    var _searchBar: CustomSearchBar

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self._searchBar = CustomSearchBar()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(searchResultsController: UIViewController?) {
        self._searchBar = CustomSearchBar()
        super.init(searchResultsController: searchResultsController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var searchBar: UISearchBar {
        return self._searchBar
    }
}

/**
 An extension of the Search such that we can use the scope bar to filter
 */
extension InvitationViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
/**
 Filtering the table based on search
 */
extension InvitationViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}