//
//  PlaylistControlView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class PlaylistControlView: UIView {

    var nowPlayingSmallView: UIView!
    var nowPlayingExpandedView: UIView!

    var topMenuBar: UIView!
    var bottomMenuBar: UIView!
    var inviteButton: UIButton!
    var leaveButton: UIButton!
    var historyButton: UIButton!
    var searchButton: UIButton!
    var titleLabel: UILabel!
    var idLabel: UILabel!


    override init(frame: CGRect) {
        super.init(frame: frame)
        print("hello, world..?")

    }

    func renderTopMenuBar() {
        historyButton = UIButton()
        historyButton.setImage(UIImage(named: "menu-alt-256"), forState: .Normal)
        // add targets
        searchButton = UIButton()
        searchButton.setImage(UIImage(named: "search"), forState: .Normal)

        topMenuBar = renderMenuBar(playlistName, leftButton: historyButton, rightButton: searchButton)
        self.addSubview(topMenuBar)
    }

    func renderBottomMenuBar() {
        leaveButton = UIButton()
        leaveButton.setImage(UIImage(named: "delete"), forState: .Normal)
        // add target
        inviteButton = UIButton()
        inviteButton.setImage(UIImage(named: "invite"), forState: .Normal)
        // add target


        bottomMenuBar = renderMenuBar(playlistId!, leftButton: leaveButton, rightButton: inviteButton)
        self.addSubview(bottomMenuBar)
    }

    func renderMenuBar(labelTitle: String, leftButton: UIButton, rightButton: UIButton) -> UIView {
        let menuBar = UIView()
        menuBar.addSubview(leftButton)
        menuBar.addSubview(rightButton)
        let label = Style.defaultLabel()
        label.text = labelTitle
        menuBar.addSubview(label)

//        menuBar.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: leftButton, attribute: .Left, relatedBy: .Equal, toItem: menuBar, attribute: .Left, multiplier: 1, constant: 10).active = true
//        NSLayoutConstraint(item: <#T##AnyObject#>, attribute: <#T##NSLayoutAttribute#>, relatedBy: <#T##NSLayoutRelation#>, toItem: <#T##AnyObject?#>, attribute: <#T##NSLayoutAttribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)




        return menuBar
    }

    func addConstraints() {

    }



    
    required init?(coder aDecoder: NSCoder) {
        fatalError("PlaylistControlView does not support NSCoding")
    }



}