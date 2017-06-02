//
//  PlayerManager.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 13/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import MediaPlayer



class PlayerManager: NSObject {
    fileprivate static var audioPlayerDelegated: AVAudioPlayer!
    fileprivate static var currentSong: Song!
    static var songList: [Song]!
    static var currentIndex: Int!
    fileprivate static var artistInfo: Artist!
    fileprivate static var timer: Timer!
    fileprivate static var delegate: SongPlayed!
    fileprivate static var currentSongData: Data!
    
    fileprivate static var player = PlayerManager()
    
    static func sharedPlayerManager() -> PlayerManager{
        return player
    }
    
    static func currentSongData(_ data: Data){
        currentSongData = data
    }
        
    static func audioPlayerStarted(_ song: Song, songList: [Song], currentIndex : IndexPath, artistInfo: Artist){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.isPlaying{
                audioPlayerDelegated.stop()
            }
        }
        
        if let url = song.fileURL{
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error{
                print(error.localizedDescription)
            }
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error{
                print(error.localizedDescription)
            }
            
            
            if !song.online{
                audioPlayerDelegated = try! AVAudioPlayer(contentsOf: url)
            }else{
                if let data = currentSongData{
                    audioPlayerDelegated = try! AVAudioPlayer(data: data)
                }
            }
            
            if let audioPlayerDelegated = audioPlayerDelegated{
                audioPlayerDelegated.play()
                
                if let timer = timer{
                    timer.invalidate()
                }
                
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
                
                //timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
                
            }
            self.currentSong = song
            self.songList = songList
            self.currentIndex = currentIndex.row
            self.artistInfo = artistInfo
            self.songList[self.currentIndex].data = currentSongData
            
            updateBlockedScreen()
            
        }
    }
    
    static func setSongPlayedDelegate(_ songPlayed: SongPlayed){
        self.delegate = songPlayed
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.isPlaying{
                let duration = Float(audioPlayerDelegated.duration)
                self.delegate.setPlayerDuration(duration)
            }
        }
    }
    
    static func setCurrentTime(_ any: Any){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.isPlaying{
                let time = Float(audioPlayerDelegated.currentTime)
                delegate.setPlayerCurrentTime(time)
                
            }
            
            if !audioPlayerDelegated.isPlaying{
                timer.invalidate()
                delegate.setPlayerCurrentTime(0.0)
                delegate.changPlayingStatus(false)
            }
            
        }
    }
    
    static func setPlayerCurrentTime(_ time: Float){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.isPlaying{
                let currentTime = TimeInterval(time)
                audioPlayerDelegated.currentTime = currentTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            }
        }
    }
    
    static func stopPlaying() {
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.isPlaying{
                audioPlayerDelegated.pause()
            }
        }
    }
    
    static func resumePlaying() {
        if let audioPlayerDelegated = audioPlayerDelegated{
            if !audioPlayerDelegated.isPlaying{
                audioPlayerDelegated.play()
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    static func playTrack(_ playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.play()
            if playTrack{
                delegate.changPlayingStatus(true)
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
            }
            let currentTime = TimeInterval(audioPlayerDelegated.currentTime)
            audioPlayerDelegated.currentTime = currentTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
    }
    
    static func pauseTrack(_ playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.pause()
        }
    }
    
    static func nextTrack(_ playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.stop()
            if let timer = timer{
                timer.invalidate()
            }
        }
        
        if songList != nil{
            if currentIndex == songList.count - 1{
                currentIndex = 0
            }else{
                currentIndex = currentIndex + 1
            }
            
            
            currentSong = songList[currentIndex]
            if let fileURL = currentSong.fileURL{
                if !currentSong.online{
                    audioPlayerDelegated = try! AVAudioPlayer(contentsOf: fileURL as URL)
                }else{
                    if let dlData = currentSong.data{
                        audioPlayerDelegated = try! AVAudioPlayer(data: dlData as Data)
                    }else{
                        if let data = currentSongData{
                            audioPlayerDelegated = try! AVAudioPlayer(data: data)
                            songList[currentIndex].data = data
                            //songList[currentIndex].data = currentSongData
                        }
                    }
                }
                    audioPlayerDelegated!.play()
                    updateBlockedScreen()
                    if playTrack {
                        delegate.setCurrentPlayedSong(currentSong)
                        let duration = Float(audioPlayerDelegated!.duration)
                        delegate.setPlayerDuration(duration)
                        delegate.changPlayingStatus(true)
                        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
                    }
                
            }
        }
        
    }
    
    static func previousTrack(_ playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.stop()
            if let timer = timer{
                timer.invalidate()
            }
        }
        
        if songList != nil{
            if currentIndex == 0{
                currentIndex = songList.count - 1
            }else{
                currentIndex = currentIndex - 1
            }
            
            
            currentSong = songList[currentIndex]
            if let fileURL = currentSong.fileURL{
                if !currentSong.online{
                    audioPlayerDelegated = try! AVAudioPlayer(contentsOf: fileURL as URL)
                }else{
                    if let dlData = currentSong.data{
                        audioPlayerDelegated = try! AVAudioPlayer(data: dlData as Data)
                    }else{
                        if let data = currentSongData{
                            audioPlayerDelegated = try! AVAudioPlayer(data: data)
                            songList[currentIndex].data = data
                            //songList[currentIndex].data = currentSongData
                        }
                    }
                }
                    audioPlayerDelegated!.play()
                    updateBlockedScreen()
                    if playTrack {
                        delegate.setCurrentPlayedSong(currentSong)
                        let duration = Float(audioPlayerDelegated!.duration)
                        delegate.setPlayerDuration(duration)
                        delegate.changPlayingStatus(true)
                        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCurrentTime(_:)), userInfo: nil, repeats: true)
                    }
                
            }
        }
    }
    
    static func updateBlockedScreen() {
        let artwork = MPMediaItemArtwork(image: UIImage(data: currentSong.artwork! as Data)!)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle : currentSong.name!,
            MPMediaItemPropertyArtist : artistInfo.name!,
            MPMediaItemPropertyArtwork : artwork,
            MPMediaItemPropertyPlaybackDuration : Float(audioPlayerDelegated!.duration),
            MPMediaItemPropertyAlbumTitle: currentSong.album!,
            MPNowPlayingInfoPropertyPlaybackRate : 1.0
        ]    }
    

    
}
