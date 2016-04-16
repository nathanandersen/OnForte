//
//  NowPlayingView.swift
//  Forte
//
//  Created by Noah Grumman on 3/30/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import UIKit
import AVFoundation
import RSPlayPauseButton
import SwiftDDP
import MediaPlayer

class NowPlayingView: UIView, AVAudioPlayerDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    var playPauseButton: RSPlayPauseButton!
    var spotifyPlayer: SPTAudioStreamingController?
    var soundcloudPlayer: AVAudioPlayer?
    var localPlayer: MPMusicPlayerController!
    
    @IBOutlet weak var serviceView: UIImageView!
    @IBOutlet weak var forwardButton: UIButton!
    
    var fullHeight: NSLayoutConstraint!

    var playlistVC: PlaylistController!
//    var playlistVC: PlaylistViewController!
    
    override func awakeFromNib() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = Style.clearColor

        if isHost {
            renderForwardButton()
            renderPlayPauseButton()
        }
        renderTitleLabel()
        renderDescriptionLabel()
        renderConstraints()
        renderSpotifyPlayer()

        if isHost {
            addConstraintsToPlayPauseButton()
            addConstraintsToForwardButton()
        }
        addConstraintsToTitleLabel()
        addConstraintsToDescriptionLabel()

        if isHost {
            localPlayer = MPMusicPlayerController.systemMusicPlayer()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NowPlayingView.handlePlaybackStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: self.localPlayer)
            localPlayer.beginGeneratingPlaybackNotifications()
        } else {
            forwardButton.hidden = true
        }
    }

    func addConstraintsToForwardButton() {
        
    }

    func addConstraintsToTitleLabel() {
        
    }

    func addConstraintsToDescriptionLabel() {

    }

    func addConstraintsToPlayPauseButton() {
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        // center vertically and horizontally
        NSLayoutConstraint(item: playPauseButton,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: albumImageView,
                           attribute: .CenterX ,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: playPauseButton,
                           attribute: .CenterY,
                           relatedBy: .Equal,
                           toItem: albumImageView,
                           attribute: .CenterY ,
                           multiplier: 1,
                           constant: 0).active = true
        // width = height
        NSLayoutConstraint(item: playPauseButton,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: playPauseButton,
                           attribute: .Height ,
                           multiplier: 1,
                           constant: 0).active = true
        NSLayoutConstraint(item: playPauseButton,
                           attribute: .Width,
                           relatedBy: .GreaterThanOrEqual,
                           toItem: nil,
                           attribute: .NotAnAttribute ,
                           multiplier: 1,
                           constant: albumImageView.frame.width / 2).active = true


        playPauseButton.updateConstraints()
    }
    
    func renderPlayPauseButton(){
        albumImageView.userInteractionEnabled = true
        playPauseButton = RSPlayPauseButton()
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        blur.frame = playPauseButton.bounds
        blur.layer.cornerRadius = playPauseButton.frame.width / 2
        blur.clipsToBounds = true
        blur.userInteractionEnabled = false //This allows touches to forward to the button.
        playPauseButton.insertSubview(blur, atIndex: 0)

        playPauseButton.tintColor = Style.primaryColor

        playPauseButton.addTarget(self, action: #selector(NowPlayingView.playPauseButtonDidPress(_:)), forControlEvents: .TouchUpInside )
        albumImageView.addSubview(playPauseButton)
    }
    
    func playPauseButtonDidPress(sender: AnyObject) {
        print("Pressed play/pause")
        if let currentSong = nowPlaying {
            switch(currentSong.service!) {
            case .Soundcloud:
                if playPauseButton.paused {
                    soundcloudPlayer?.play()
                } else {
                    soundcloudPlayer?.pause()
                }
            case .Spotify:
                spotifyPlayer?.setIsPlaying(playPauseButton.paused,callback: nil)
            case .iTunes:
                playPauseButton.paused ? localPlayer.play() : localPlayer.pause()
            }
            playPauseButton.setPaused(!playPauseButton.paused,animated: true)
        } else {
            playNextSong()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }
    
    func playNextSong() {
        if let nextSong = playlistVC.getNextSong() {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
//            print(nextSong)
            nowPlaying = nextSong
            self.updateTrackDisplay()
            self.playPauseButton.setPaused(false, animated: true)

            switch(nowPlaying!.service!){
            case .Soundcloud:
                playSoundCloud()
            case .Spotify:
                playSpotify()
            case .iTunes:
                playLocalSong()
            }
            self.registerNextSongWithServer(nextSong)
//            self.server_markCurrentSongAsPlayed(nextSong)
//            self.server_sendNextSong(nextSong)
        } else {
//            playlistVC.hideNowPlayingView()
            nowPlaying = nil
        }
    }
    
    func stop() {
        spotifyPlayer?.setIsPlaying(false,callback: nil)
//        spotifyPlayer?.stop(nil)
        print("1")
        soundcloudPlayer?.stop()
        print("2")
        localPlayer.stop()
        // ^ this line takes a long time
        print("3")
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("AVAudioSession is no longer active")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        print("4")
    }

    func playLocalSong() {
//         localPlayer.setQueueWithStoreIDs(storeIds: [String]) <- OOH

        let index: Int = Int(nowPlaying!.trackId!)!
        let nowPlayingItem: MPMediaItem! = allLocalITunesOriginals![index]

        let itemCollection: MPMediaItemCollection = MPMediaItemCollection(items: [nowPlayingItem])

        localPlayer.setQueueWithItemCollection(itemCollection)
        localPlayer.prepareToPlay()
        localPlayer.repeatMode = .None
        localPlayer.play()
    }

    func handlePlaybackStateChanged(notification: NSNotification) {
        if (self.localPlayer.playbackState == .Stopped) {
            print("next song")
            playNextSong()
        }
    }


    func playSoundCloud() {
        let url = "https://api.soundcloud.com/tracks/" + (nowPlaying?.trackId)! + "/stream?client_id=50ea1a6c977ecf3fb47ecaf6078c388b"
        print(url)
        let soundData = NSData(contentsOfURL: NSURL(string: url)!)
        soundcloudPlayer = try? AVAudioPlayer(data: soundData!)
        // ^ this takes a while, surprisingly.
        // maybe let's see if the SDK has changed
        
        if let p = soundcloudPlayer {
            p.prepareToPlay()
            p.delegate = self
            p.volume = 1.0
            p.play()
            print("Soundcloud is playing track")
        } else {
            print("Soundcloud player failed.")
            playPauseButton.setPaused(true, animated: true)
        }
    }
    
    func playSpotify() {
        if spotifySession == nil {
            print("not logged into spotify!")
            let alertController = UIAlertController(title: "Spotify disabled", message: "Please have the host log in to spotify.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            playlistVC.presentViewController(alertController, animated: true, completion: {
//                self.playlistVC.hideNowPlayingView()
                nowPlaying = nil
            })
            return
        } else {
            spotifyPlayer!.loginWithSession(spotifySession, callback: { (error: NSError?) in
                if (error != nil) {
                    print("Logging had error:")
                    print(error)
                    self.playPauseButton.setPaused(true, animated: true)
                    return
                }})
            let trackId: String = nowPlaying!.trackId!
            let trackURI: NSURL = NSURL(string: ("spotify:track:"+String(trackId)))!
            print(trackURI)
            spotifyPlayer!.playURI(trackURI, callback: {(error: NSError?) in
                if (error != nil) {
                    print("Starting playback had error")
                    print(error)
                    self.playPauseButton.setPaused(true, animated: true)
                    return
                }
            })
        }

        playPauseButton.setPaused(false, animated: true)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata == nil {
            print("song ended")
        }
    }

    func registerNextSongWithServer(song: Song ) {

        let paramObj = [playlistId!,
                        (song.title != nil) ? song.title! : "",
                        (song.description != nil) ? song.description! : "",
                        String(song.service!),
                        (song.trackId != nil) ? song.trackId! : "",
                        (song.artworkURL != nil) ? String(song.artworkURL!) : ""]

        Meteor.call("registerSongAsPlayed",params: paramObj,callback: nil)

        Meteor.call("removeSongFromQueue",params: [song.id!],callback: nil)
        Meteor.call("markSongAsPlayed",params: [song.id!],callback: nil)
    }
    
/*   func server_markCurrentSongAsPlayed(song: Song){
        Meteor.call("registerSongAsPlayed",params: [playlistId!,song.getSongDocFields()],callback: nil)
        Meteor.call("setSongAsPlaying",params: [playlistId!,song.getSongDocFields()],callback: nil)
        //        Meteor.call("markSongAsPlayed",params: [song.id!],callback: nil)
    }
    
    func server_sendNextSong(song: Song) {
        Meteor.call("setSongAsPlaying",params: [playlistId!,song.getSongDocFields()],callback: nil)
    }*/

    func updateTrackDisplay() {
//        print("now playing updated")
//        nowPlaying?.printToConsole()
        let title = nowPlaying?.title
        let description = nowPlaying?.description
        let service = nowPlaying?.service!
        let albumImageURL = nowPlaying?.artworkURL

        titleLabel.text = title
        descriptionLabel.text = description
        if let s = service {
            switch(s){
            case .Spotify:
                serviceView.image = UIImage(named: "spotify")
            case .Soundcloud:
                serviceView.image = UIImage(named: "soundcloud")
            case .iTunes:
                serviceView.image = UIImage(named: "itunes")
            }
        }
        artworkHandler.lookupForImageView(albumImageURL, imageView: albumImageView)


    }
    
    func renderConstraints(){
        self.clipsToBounds = true
        fullHeight = NSLayoutConstraint(item: self,
                                        attribute: .Height,
                                        relatedBy: .Equal,
                                        toItem: nil,
                                        attribute: .NotAnAttribute,
                                        multiplier: 1,
                                        constant: 85)
        fullHeight.active = true
        self.updateConstraints()
    }
    
    func renderTitleLabel(){
        titleLabel = Style.defaultLabel()
        titleLabel.textAlignment = .Left
        titleView.backgroundColor = Style.clearColor
        self.addSubview(titleLabel)
        
        let constraints = Style.constrainToBoundsOfFrame(titleLabel, parentView: titleView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func renderDescriptionLabel(){
        descriptionLabel = Style.defaultLabel()
        descriptionView.backgroundColor = Style.clearColor
        descriptionLabel.textAlignment = .Left
        descriptionLabel.font = Style.defaultFont(10)
        self.addSubview(descriptionLabel)
        
        let constraints = Style.constrainToBoundsOfFrame(descriptionLabel, parentView: descriptionView)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }

    func fastForward() {
        activityIndicator.showActivity("Skipping")
        stop()
        playNextSong()
        activityIndicator.showComplete("Skipped")
    }

    func renderForwardButton(){
        forwardButton.tintColor = Style.grayColor
        forwardButton.addTarget(self, action: #selector(NowPlayingView.fastForward), forControlEvents: .TouchUpInside)
        forwardButton.showsTouchWhenHighlighted = true
    }
    
    func renderSpotifyPlayer(){
        spotifyPlayer = SPTAudioStreamingController.init(clientId: SPTAuth.defaultInstance().clientID)
        spotifyPlayer?.playbackDelegate = self
    }
    
    class func instanceFromNib() -> NowPlayingView {
        return UINib(nibName: "NowPlayingView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! NowPlayingView
    }

}
