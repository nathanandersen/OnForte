//
//  IntegratedMusicPlayer.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/16/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation
import SwiftDDP

class IntegratedMusicPlayer: NSObject, AVAudioPlayerDelegate, SPTAudioStreamingPlaybackDelegate {

    var spotifyPlayer: SPTAudioStreamingController
    var soundcloudPlayer: AVAudioPlayer?
    var localPlayer: MPMusicPlayerController
    var playlistController: PlaylistController!
    var control: MusicPlayerView!

    var playing: Bool

    override init() {
        spotifyPlayer = SPTAudioStreamingController.init(clientId: SPTAuth.defaultInstance().clientID)
        localPlayer = MPMusicPlayerController.applicationMusicPlayer()
        playing = false
        super.init()
        spotifyPlayer.playbackDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NowPlayingView.handlePlaybackStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: self.localPlayer)
        localPlayer.beginGeneratingPlaybackNotifications()
    }

    func togglePlayingStatus() {
        print("Pressed play/pause")
        if let currentSong = nowPlaying {
            switch(currentSong.service!) {
            case .Soundcloud:
                if playing {
                    soundcloudPlayer?.pause()
                } else {
                    soundcloudPlayer?.play()
                }
            case .Spotify:
                spotifyPlayer.setIsPlaying(!playing,callback: nil)
            case .iTunes:
                playing ? localPlayer.pause() : localPlayer.play()
            }
            playing = !playing
            // set paused button to target


        } else {
            playNextSong()
        }

    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }

    func registerNextSongWithServer(song: Song ) {
        print("well, that happened")
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

    func playNextSong() {
        print(playlistController)
        if let nextSong = playlistController.getNextSong() {
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
            print(nextSong)
            nowPlaying = nextSong

            playing = true
            control.setPlayButtonStatus(playing)

            //            self.updateTrackDisplay()
            switch(nowPlaying!.service!){
            case .Soundcloud:
                playSoundCloud()
            case .Spotify:
                playSpotify()
            case .iTunes:
                playLocalSong()
            }
            self.registerNextSongWithServer(nextSong)
        } else {
            nowPlaying = nil
            playing = false
            control.setPlayButtonStatus(playing)
        }
    }


    func handlePlaybackStateChanged(notification: NSNotification) {
        if (self.localPlayer.playbackState == .Stopped) {
            print("next song")
            self.playNextSong()
        }
    }

    func stop() {
        spotifyPlayer.setIsPlaying(false,callback: nil)
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
        let index: Int = Int(nowPlaying!.trackId!)!
        let nowPlayingItem: MPMediaItem! = allLocalITunesOriginals![index]
        let itemCollection: MPMediaItemCollection = MPMediaItemCollection(items: [nowPlayingItem])
        localPlayer.setQueueWithItemCollection(itemCollection)
        localPlayer.prepareToPlay()
        localPlayer.repeatMode = .None
        localPlayer.play()
        playing = true
        control.setPlayButtonStatus(playing)
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
            playing = true
            control.setPlayButtonStatus(playing)
        } else {
            print("Soundcloud player failed.")
            playing = false
            control.setPlayButtonStatus(playing)
        }
    }

    func playSpotify() {
        if spotifySession == nil {
            print("not logged into spotify!")

             let alertController = UIAlertController(title: "Spotify disabled", message: "Please have the host log in to spotify.", preferredStyle: .Alert)
             let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in

             }
             alertController.addAction(cancelAction)
             self.playlistController.presentViewController(alertController, animated: true, completion: {
//             self.playlistVC.hideNowPlayingView()
                // ^^^?!?!?!?
             nowPlaying = nil
             })
            return
        } else {
            spotifyPlayer.loginWithSession(spotifySession, callback: { (error: NSError?) in
                if (error != nil) {
                    print("Logging had error:")
                    print(error)
                    self.playing = false
                    self.control.setPlayButtonStatus(self.playing)
                    return
                }})
            let trackURI: NSURL = NSURL(string: ("spotify:track:"+String(nowPlaying!.trackId!)))!
            print(trackURI)
            spotifyPlayer.playURI(trackURI, callback: {(error: NSError?) in
                if (error != nil) {
                    print("Starting playback had error")
                    print(error)
                    self.playing = false
                    self.control.setPlayButtonStatus(self.playing)
                    return
                }
            })
        }
        playing = true
        control.setPlayButtonStatus(playing)
    }


    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata == nil {
            print("song ended")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("MusicPlayer does not support NSCoding")
    }
}