//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UIPageViewControllerDelegate,UIPageViewControllerDataSource, AudioPlayerStarted{

    var artistsPageLoader: UIPageViewController!
    var artistPages = [ArtistInfoViewController]()
    var audioPlayerDelegated: AVAudioPlayer?
    var timer: NSTimer!
    var delegate: SongPlayed!
    var currentSong: Song!
    var songList: [Song]!
    var currentIndex: Int!
    var artistInfo: Artist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        //Aqui se deberia cargar la data del sitio
        
        let artistsInfo = [ArtistInfo(image: UIImage(named: "charlieparker")!, name: "Charlie Parker", news: "Charles Christopher Parker, Jr. (Kansas City, 29 de agosto de 1920 - Nueva York, 12 de marzo de 1955), conocido como Charlie Parker, fue un saxofonista y compositor estadounidense de jazz."),
                           ArtistInfo(image: UIImage(named: "coldplay")!,name: "Coldplay", news: "Coldplay are a British rock band formed in 1996 by lead vocalist and pianist Chris Martin and lead guitarist Jonny Buckland at University College London"),
                           ArtistInfo(image: UIImage(named: "patmetheny")!,name: "Pat Metheny", news: "He is the leader of the Pat Metheny Group and is also involved in duets, solo works and other side projects. His style incorporates elements of progressive and contemporary jazz, post-bop, Latin jazz and jazz fusion")]
        
        for index in 0..<artistsInfo.count{
            if let artistController = self.storyboard?.instantiateViewControllerWithIdentifier("ArtistInfo") as? ArtistInfoViewController{
                
                let artist = Artist(name: artistsInfo[index].name, biography: artistsInfo[index].news, image: artistsInfo[index].image)
                
                switch index {
                case 0:
                    artist.songList.append(Song(name: "Bloomdido", album: "Bird And Diz", artwork: UIImage(named: "BirdAndDiz")!, path: NSBundle.mainBundle().pathForResource("Bloomdido", ofType: "mp3")!))
                    artist.songList.append(Song(name: "Scrapple From The Apple", album: "Bird And Diz", artwork: UIImage(named: "BirdAndDiz")!, path: NSBundle.mainBundle().pathForResource("ScrappleFromTheApple", ofType: "mp3")!))
                case 1:
                    artist.songList.append(Song(name: "Don't Panic", album: "Parachutes", artwork: UIImage(named: "Parachutes")!, path: NSBundle.mainBundle().pathForResource("DontPanic", ofType: "mp3")!))
                    artist.songList.append(Song(name: "Adventure Of A Lifetime", album: "A Head Full Of Dreams", artwork: UIImage(named: "AHeadFullOfDreams")!, path: NSBundle.mainBundle().pathForResource("AdventureOfALifetime", ofType: "mp3")!))
                    
                case 2:
                    artist.songList.append(Song(name: "So It May Secretly Begin", album: "Still Life(Talking)", artwork: UIImage(named: "StillLife")!, path: NSBundle.mainBundle().pathForResource("SoItMaySecretlyBegin", ofType: "mp3")!))
                    artist.songList.append(Song(name: "Au Lait", album: "Offramp", artwork: UIImage(named: "Offramp")!, path: NSBundle.mainBundle().pathForResource("AuLait", ofType: "mp3")!))
                default:
                    break
                }
                
                
                artistController.artistInfo = artist
                artistController.pageIndex = index
                artistController.delegate = self
                
                
                artistPages.append(artistController)
                
            }
        }
        
        if let firstArtistPage = artistPages.first{
            self.artistsPageLoader.setViewControllers([firstArtistPage], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoadArtistInfo"{
            artistsPageLoader = segue.destinationViewController as! UIPageViewController
            
            artistsPageLoader.dataSource = self
            artistsPageLoader.delegate = self
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if songList != nil{
            nextTrack(false)
        }
    }
    
    //MARK: - UIPageControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = -1
        
        if let vc = viewController as? ArtistInfoViewController{
            index = vc.pageIndex - 1
        }
        
        if index >= 0 && index < artistPages.count{
            return artistPages[index]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = -1
        
        if let vc = viewController as? ArtistInfoViewController{
            index = vc.pageIndex + 1
        }
        
        if index >= 0 && index < artistPages.count{
            return artistPages[index]
        }
        
        return nil
    }
    
    //MARK: - AudioPlayerStarted
    
    func audioPlayerStarted(song: Song, songList: [Song], currentIndex : NSIndexPath, artistInfo: Artist){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.playing{
                audioPlayerDelegated.stop()
            }
        }
        
        if let url = song.fileURL{
            audioPlayerDelegated = try! AVAudioPlayer(contentsOfURL: url)
            if let audioPlayerDelegated = audioPlayerDelegated{
                audioPlayerDelegated.play()
                
                if let timer = timer{
                    timer.invalidate()
                }
                
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.setCurrentTime(_:)), userInfo: nil, repeats: true)
                
            }
            self.currentSong = song
            self.songList = songList
            self.currentIndex = currentIndex.row
            self.artistInfo = artistInfo
            
            updateBlockedScreen()
            
        }
    }
    
    func setSongPlayedDelegate(songPlayed: SongPlayed){
        self.delegate = songPlayed
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.playing{
                let duration = Float(audioPlayerDelegated.duration)
                self.delegate.setPlayerDuration(duration)
            }
        }
    }
    
    func setCurrentTime(notification: NSNotification){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.playing{
                let time = Float(audioPlayerDelegated.currentTime)
                delegate.setPlayerCurrentTime(time)
                
            }
            
            if !audioPlayerDelegated.playing{
                timer.invalidate()
                delegate.setPlayerCurrentTime(0.0)
                delegate.changPlayingStatus(false)
            }
            
        }
    }
    
    func setPlayerCurrentTime(time: Float){
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.playing{
                let currentTime = NSTimeInterval(time)
                audioPlayerDelegated.currentTime = currentTime
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            }
        }
    }
    
    func stopPlaying() {
        if let audioPlayerDelegated = audioPlayerDelegated{
            if audioPlayerDelegated.playing{
                audioPlayerDelegated.pause()
            }
        }
    }
    
    func resumePlaying() {
        if let audioPlayerDelegated = audioPlayerDelegated{
            if !audioPlayerDelegated.playing{
                audioPlayerDelegated.play()
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.setCurrentTime(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    func playTrack(playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.play()
            if playTrack{
                delegate.changPlayingStatus(true)
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.setCurrentTime(_:)), userInfo: nil, repeats: true)
            }
            let currentTime = NSTimeInterval(audioPlayerDelegated.currentTime)
            audioPlayerDelegated.currentTime = currentTime
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
    }
    
    func pauseTrack(playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.pause()
        }
    }
    
    func nextTrack(playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.stop()
        }
        
        if songList != nil{
            if currentIndex == songList.count - 1{
                currentIndex = 0
            }else{
                currentIndex = currentIndex + 1
            }
            
            
            currentSong = songList[currentIndex]
            if let fileURL = currentSong.fileURL{
                audioPlayerDelegated = try! AVAudioPlayer(contentsOfURL: fileURL)
                audioPlayerDelegated!.play()
                updateBlockedScreen()
                if playTrack {
                    delegate.setCurrentPlayedSong(currentSong)
                    let duration = Float(audioPlayerDelegated!.duration)
                    delegate.setPlayerDuration(duration)
                    delegate.changPlayingStatus(true)
                    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.setCurrentTime(_:)), userInfo: nil, repeats: true)
                }
            }
        }
        
    }
    
    func previousTrack(playTrack: Bool){
        if let audioPlayerDelegated = audioPlayerDelegated{
            audioPlayerDelegated.stop()
        }
        
        if songList != nil{
            if currentIndex == 0{
                currentIndex = songList.count - 1
            }else{
                currentIndex = currentIndex - 1
            }
            
            
            currentSong = songList[currentIndex]
            if let fileURL = currentSong.fileURL{
                audioPlayerDelegated = try! AVAudioPlayer(contentsOfURL: fileURL)
                audioPlayerDelegated!.play()
                updateBlockedScreen()
                if playTrack {
                    delegate.setCurrentPlayedSong(currentSong)
                    let duration = Float(audioPlayerDelegated!.duration)
                    delegate.setPlayerDuration(duration)
                    delegate.changPlayingStatus(true)
                    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.setCurrentTime(_:)), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    //MARK: - RemoteControls
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
     
         switch event!.subtype {
            case .RemoteControlPlay:
                playTrack(false)
                break
            case .RemoteControlPause:
                pauseTrack(false)
                break
            case .RemoteControlNextTrack:
                nextTrack(false)
                break
            case .RemoteControlPreviousTrack:
                previousTrack(false)
                break
            default:
                break
        }
     
    }
    
    func updateBlockedScreen() {
        let artwork = MPMediaItemArtwork(image: currentSong.artwork)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle : currentSong.name,
            MPMediaItemPropertyArtist : artistInfo.name,
            MPMediaItemPropertyArtwork : artwork,
            MPMediaItemPropertyPlaybackDuration : Float(audioPlayerDelegated!.duration),
            MPMediaItemPropertyAlbumTitle: currentSong.album,
            MPNowPlayingInfoPropertyPlaybackRate : 1.0
        ]    }
}

