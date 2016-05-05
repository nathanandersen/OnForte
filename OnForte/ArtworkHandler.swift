//
//  ArtworkHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import Alamofire
//import SwiftyJSON

/**
 This is a cache for artwork music
 */
class ArtworkHandler {

    var artworkCache: NSCache!

    init() {
        artworkCache = NSCache()
    }


    /**
     Lookup artwork, if it's in the cache return the UIImage, else search it, cache it, and return it.
    */

    func lookupArtwork(lookupURL: NSURL?) -> UIImage? {
        if let url = lookupURL {
            if let image = self.artworkCache.objectForKey(url) as? UIImage {
                print("cache hit for image")
                return image
            } else {
                print("cache miss")
                if let albumArtData = NSData(contentsOfURL: url){
                    if let albumArt = UIImage(data: albumArtData){
                        self.artworkCache.setObject(albumArt, forKey: url)
                        return albumArt
                    }
                    print("album art no good")
                }
                print("couldn't make data")
            }
        } else {
            print("url was invalid")
        }


        return UIImage()
    }

    /**
     Given a table view cell and an image view, lookup the artwork and insert it into the cell
    */
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

    /**
     Given a image view, look up the artwork
     */
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
                                imageView!.image = albumArt
                                imageView?.setNeedsLayout()

                            }
                        }
                    }
                }
            }
        }
    }

}