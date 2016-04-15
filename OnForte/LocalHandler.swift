//
//  iTunesSearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDDP
import SwiftyJSON

class LocalHandler: NSObject, SearchHandler {
    
    var results: [Song] = []

    func clearSearch() {
        results = [Song]()
    }

    func search(query: String) {
        if (query != ""){
            results = allLocalITunes.filter({ (song) -> Bool in
                //            iTunesResults = (UIApplication.sharedApplication().delegate as! AppDelegate).allLocalITunes.filter({ (song) -> Bool in
                let title: NSString = song.title!
                let range = title.rangeOfString(query, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            })
        }
        else {
            results = []
        }
    }

    /*
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     return 1
     }
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    /*
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     return nil
     }

     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 0
     }*/

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultsTableViewCell")! as! SearchResultsTableViewCell
        cell.loadItem(results[indexPath.row])


        cell.albumImage.image = UIImage(named: "itunes_gray")

        print(results[indexPath.row].artworkURL)

        if (results[indexPath.row].artworkURL != nil) {
            cell.albumImage.image = artworkHandler.artworkCache.objectForKey(self.results[indexPath.row].artworkURL!) as? UIImage
        }
        else {
            print("Cache miss on iTunes album artwork")

            let parameters = [
                "term": self.results[indexPath.row].title! + " " + self.results[indexPath.row].description!,
                "entity":"song",
                "limit": "1"
            ]

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

                Alamofire.request(.GET, "https://itunes.apple.com/search", parameters: parameters).responseJSON { response in

                    guard response.result.error == nil else {
                        print("Error occurred during itunes album art request")
                        print(response.result.error!)
                        return
                    }

                    if let response_string = response.result.value {
                        let response_json = JSON(response_string)

                        if response_json["resultCount"] == 1 {

                            if let url = NSURL(string: response_json["results"][0]["artworkUrl100"].string!) {

                                self.results[indexPath.row].artworkURL = url

                                let albumArt = NSData(contentsOfURL: url)
                                artworkHandler.artworkCache.setObject(UIImage(data: albumArt!)!, forKey: url)
                                dispatch_async(dispatch_get_main_queue()) {
                                    cell.albumImage.image = UIImage(data: albumArt!)
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                    }

                }
            }
        }

        print(results[indexPath.row].title! + " " + results[indexPath.row].description!)

        return cell;
    }



    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityIndicator.showActivity("Adding Song")
        addSongToPlaylist(results[indexPath.row])

    }

    func addSongToPlaylist(song: Song) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            activityIndicator.showComplete("Added")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
    }

}