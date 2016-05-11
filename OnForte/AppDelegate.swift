//
//  AppDelegate.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import UIKit
import SwiftDDP
import MediaPlayer
import Soundcloud
import MMDrawerController
import CoreData

enum Storyboard: String {
    case Main = "Main"
    case Onboarding = "Onboarding"
}

let onboardingKey = "onboardingShown"
//let autoRefresh = "autoRefreshEnabled"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchURL: String? = nil
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    // iTunes: load and parse all songs from local library
    func loadAllLocalSongs() {
        print("Loading all items from local library")

        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            allLocalITunesOriginals = MPMediaQuery.songsQuery().items
            if allLocalITunesOriginals == nil {
                return
            }

            var songs: [Song] = []
            if allLocalITunesOriginals!.count > 0 {
                for i in 0...(allLocalITunesOriginals!.count-1){
                    let track = allLocalITunesOriginals![i]
                    let song = Song(
                        title: track.title,
                        description: track.albumTitle,
                        service: Service.iTunes,
                        trackId: String(i),
                        artworkURL: nil)
                    songs += [song]
                }
            }


            // track Id will be an index for the MPMediaItem

            allLocalITunes = songs
            print("Loaded all items from local library")
        })
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSLog("application launched")

        if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }

        activityIndicator = ActivityIndicator(frame: CGRectMake(5, 20, 40, 40))

        SPTAuth.defaultInstance().clientID = keys!["SpotifyClientId"] as! String
        SPTAuth.defaultInstance().redirectURL = NSURL(string: keys!["SpotifyRedirectURI"] as! String)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifySession"
        SPTAuth.defaultInstance().tokenSwapURL = NSURL(string: keys!["SpotifyTokenSwapURL"] as! String)
        SPTAuth.defaultInstance().tokenRefreshURL = NSURL(string: keys!["SpotifyTokenRefreshURL"] as! String)
        Soundcloud.clientIdentifier = keys!["SoundcloudClientId"] as? String
        Soundcloud.clientSecret = keys!["SoundcloudClientSecret"] as? String


        loadAllLocalSongs()

        defaults.registerDefaults(
            [onboardingKey: false]
        )

        if ( !defaults.boolForKey(onboardingKey)) {
            launchStoryboard(Storyboard.Main)
        } else {
            launchStoryboard(Storyboard.Main)
        }

        return true
    }


    func launchStoryboard(storyboardChoice: Storyboard) {
        let storyboard = UIStoryboard(name: storyboardChoice.rawValue, bundle: nil)
        if storyboardChoice == .Main {
            let controller = storyboard.instantiateViewControllerWithIdentifier("CentralNavigationController")
            self.window?.rootViewController = controller
        } else {
            let controller = storyboard.instantiateViewControllerWithIdentifier("OnboardingInitialViewController")
            self.window?.rootViewController = controller
        }
    }

    func launchPlaylist(playlistID: String) {

        let storyboard = UIStoryboard(name: Storyboard.Main.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("CentralNavigationController")
        self.window?.rootViewController = controller

        ((controller as! CentralNavigationController).presentedViewController as! RootViewController).joinPlaylistFromURL(playlistID)
    }

    func application(application: UIApplication,openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if sourceApplication != nil && sourceApplication == "com.apple.mobilesafari" {
            print("Opening from deep link")
            if let playlistID = url.host {
                if playlistID.characters.count == 6 {
                    launchPlaylist(playlistID)
                }
            }

        }
        //        else if sourceApplication != nil && sourceApplication == "com.apple.SafariViewService" {
//        print("Opening from deep link")
        activityIndicator.showActivity("Confirming login")
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: {(error:NSError?,session: SPTSession?) in
                if error != nil {
                    print("was error!!")
                    print(error)
                    // alert... login failed!
                    return
                }
                spotifySession = session
                activityIndicator.showComplete("")
                NSNotificationCenter.defaultCenter().postNotificationName("didLogInToSpotify", object: nil)
            })
            return true
        }
        activityIndicator.showComplete("Failed")
        // alert.. login failed!
        return false
        //        }
//        return false

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSLog("Application Will Resign Active")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog("application did enter background")
        self.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSLog("application will enter foreground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("application did become active")
        activityIndicator.showActivity("Connecting")

        // can we refresh the spotify session here?

        Meteor.connect("wss://onforte.herokuapp.com/websocket") {
            print("Connected to Forte")
            activityIndicator.showComplete("Connected")
            if playlistId != nil {
                Meteor.subscribe("songs",params: [playlistId!])
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog("application will terminate")
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("OnForte.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
}


