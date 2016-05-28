//
//  PlayedSongCollection.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP

/*func debounce( delay:NSTimeInterval, queue:dispatch_queue_t, action: (()->()) ) -> ()->() {

 var lastFireTime:dispatch_time_t = 0
 let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))

 return {
 lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
 dispatch_after(
 dispatch_time(
 DISPATCH_TIME_NOW,
 dispatchDelay
 ),
 queue) {
 let now = dispatch_time(DISPATCH_TIME_NOW,0)
 let when = dispatch_time(lastFireTime, dispatchDelay)
 if now >= when {
 action()
 }
 }
 }
 }*/

class PlaylistSongHistory: MeteorCollection<PlayedSongDocument> {
    let collectionSetDidChange = debounce(NSTimeInterval(0.33), queue: dispatch_get_main_queue(), action: {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            NSNotificationCenter.defaultCenter().postNotificationName(METEOR_COLLECTION_SET_DID_CHANGE, object: nil)
        }
    })
    var documents = [String:PlayedSongDocument]()
    var keys = [String]()

    /**
     Returns the number of documents in the collection
     */
    override var count:Int {
        return documents.count
    }
    /**
     Initializes a MeteorCollection object

     - parameter name:   The string name of the collection (must match the name of the collection on the server)
     */
    internal override init(name: String) {
        super.init(name: name)
    }
    /*
     private func index(id: String) -> Int? {
     return sorted.indexOf({item in item._id == id})
     }*/

    func clear() {
        documents = [String:PlayedSongDocument]()
        keys = [String]()
    }

    /**
     Find a single document by id

     - parameter id: the id of the document
     */
    override func findOne(id: String) -> PlayedSongDocument? {
        return documents[id]
    }

    /**
     Invoked when a document has been sent from the server.

     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     - parameter fields:         an optional NSDictionary with the documents properties
     */
    internal override func documentWasAdded(collection:String, id:String, fields:NSDictionary?) {
        let document = PlayedSongDocument(id: id, fields: fields)
        self.documents[id] = document
        keys.insert(id, atIndex: 0)
        collectionSetDidChange()
        NSNotificationCenter.defaultCenter().postNotificationName(updateHistoryTableKey, object: nil)
    }

    /**
     Invoked when a document has been changed on the server.

     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     - parameter fields:         an optional NSDictionary with the documents properties
     - parameter cleared:                    Optional array of strings (field names to delete)
     */

    internal override func documentWasChanged(collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {
        if let document = documents[id] {
            document.update(fields, cleared: cleared)
            self.documents[id] = document
            collectionSetDidChange()
        }
    }

    /**
     Invoked when a document has been removed on the server.

     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     */

    internal override func documentWasRemoved(collection:String, id:String) {
        if let _ = documents[id] {
            self.documents[id] = nil
            collectionSetDidChange()
            keys.removeAtIndex(keys.indexOf(id)!)
        }
    }

    /**
     Client-side method to insert a document

     - parameter document:       a document that inherits from MeteorDocument
     */
    //basically taken from the source doc
    /*    override internal func insert(document: SongDocument) {
     documents[document._id] = document
     collectionSetDidChange()
     client.insert(self.name, document: [document.getFields()]) { result, error in
     if error != nil {
     self.documents[document._id] = nil
     self.collectionSetDidChange()
     print(error)
     }
     }
     }*/

    /**
     Client-side method to remove a document

     - parameter document:       a document that inherits from MeteorDocument
     */
    /*
     public func remove(document: SongDocument) {
     documents[document._id] = nil
     collectionSetDidChange()

     client.remove(self.name, document: [["_id":document._id]]) { result, error in

     if error != nil {
     self.documents[document._id] = document
     self.collectionSetDidChange()
     log.error("\(error!)")
     }

     }
     }*/
}