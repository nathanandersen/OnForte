//
//  ArtworkHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ArtworkHandler {

    var artworkCache: NSCache!

    init() {
        artworkCache = NSCache()
    }

    func lookupForCell(lookupURL: NSURL?, imageView: UIImageView?, cell: UITableViewCell) {
        if let url = lookupURL {
            if (self.artworkCache.objectForKey(url) != nil){
                print("Cache hit for: " + url.absoluteString)
                imageView!.image = artworkCache.objectForKey(url) as? UIImage
            }
            else {
                print("Cache miss for: " + url.absoluteString)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    if let albumArtData = NSData(contentsOfURL: url){
                        if let albumArt = UIImage(data: albumArtData){
                            dispatch_async(dispatch_get_main_queue()) {
                                self.artworkCache.setObject(albumArt, forKey: url)
                                imageView!.image = self.artworkCache.objectForKey(url) as? UIImage
                                cell.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
    }

    func lookupForImageView(lookupURL: NSURL?, imageView: UIImageView?) {
        if let url = lookupURL {
            if (self.artworkCache.objectForKey(url) != nil){
                print("Cache hit for: " + url.absoluteString)
                imageView!.image = artworkCache.objectForKey(url) as? UIImage
            }
            else {
                print("Cache miss for: " + url.absoluteString)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    if let albumArtData = NSData(contentsOfURL: url){
                        if let albumArt = UIImage(data: albumArtData){
                            dispatch_async(dispatch_get_main_queue()) {
                                self.artworkCache.setObject(albumArt, forKey: url)
                                imageView!.image = self.artworkCache.objectForKey(url) as? UIImage
                                imageView?.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
    }

}