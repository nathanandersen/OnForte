//
//  SearchResultsTableViewCell.swift
//  Forte
//
//  Created by Noah Grumman on 3/23/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    @IBOutlet var albumImage: UIImageView!
    
    
    @IBOutlet var titleLabelView: UIView!
    @IBOutlet var descriptionLabelView: UIView!
    var titleLabel: UILabel?
    var descriptionLabel: UILabel?
    
    override func awakeFromNib() {
        // initialization
        super.awakeFromNib()
        renderTitleLabel()
        renderDescriptionLabel()
//        initializeBackground()
    }
    
    func renderTitleLabel() {
        let label = Style.defaultLabel()
        label.textAlignment = .Left
        titleLabelView.addSubview(label)
        titleLabelView.backgroundColor = Style.clearColor

        let constraints = Style.constrainToBoundsOfFrame(label, parentView: titleLabelView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        titleLabel = label
    }
    
    func renderDescriptionLabel() {
        let label = Style.defaultLabel()
        label.backgroundColor = Style.clearColor
        label.textAlignment = .Left
        label.font = Style.defaultFont(10)
        descriptionLabelView.addSubview(label)
        descriptionLabelView.backgroundColor = Style.clearColor
        
        let constraints = Style.constrainToBoundsOfFrame(label, parentView: descriptionLabelView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        
        descriptionLabel = label
    }
    
    func loadItem(song: Song) {
        var source: String = ""
        switch (song.service!) {
        case .Soundcloud:
            source = "soundcloud"
        case .iTunes:
            source = "itunes_gray"
        case .Spotify:
            source = "spotify"
        }
        albumImage.image = UIImage(named: source)
        titleLabel!.text = song.title
        descriptionLabel!.text = song.description

    }
    
    func initializeBackground(){
        let backgroundView : UIView = UIView(frame: CGRectMake(0, 5, self.frame.size.width, 75))
        backgroundView.layer.backgroundColor = Style.whiteColor.CGColor
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowColor = Style.blackColor.CGColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowOffset = CGSizeZero
        self.contentView.addSubview(backgroundView)
        self.contentView.sendSubviewToBack(backgroundView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
