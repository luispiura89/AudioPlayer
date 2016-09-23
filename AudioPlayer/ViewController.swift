//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class ViewController: UIViewController, UIPageViewControllerDelegate,UIPageViewControllerDataSource{

    var artistsPageLoader: UIPageViewController!
    var artistPages = [ArtistInfoViewController]()
    var audioPlayerDelegated: AVAudioPlayer?
    //var timer: NSTimer!
    var delegate: SongPlayed!
    var currentSong: Song!
    var songList: [Song]!
    var currentIndex: Int!
    var artistInfo: Artist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Aqui se deberia cargar la data del sitio
        let artistsInfo = [ArtistInfo(image: UIImage(named: "charlieparker")!, name: "Charlie Parker", news: "Charles Christopher Parker, Jr. (Kansas City, 29 de agosto de 1920 - Nueva York, 12 de marzo de 1955), conocido como Charlie Parker, fue un saxofonista y compositor estadounidense de jazz."),
                           ArtistInfo(image: UIImage(named: "coldplay")!,name: "Coldplay", news: "Coldplay are a British rock band formed in 1996 by lead vocalist and pianist Chris Martin and lead guitarist Jonny Buckland at University College London"),
                           ArtistInfo(image: UIImage(named: "patmetheny")!,name: "Pat Metheny", news: "He is the leader of the Pat Metheny Group and is also involved in duets, solo works and other side projects. His style incorporates elements of progressive and contemporary jazz, post-bop, Latin jazz and jazz fusion")]
        
        /*
        let query = Query(className: Artist.ClassName)
        if let res = query.find() as? [Artist]{
            print(res.count)
            for r in res{
                print(r.songlist?.allObjects.count)
            }
            print("==========")
        }
        */
        
        for index in 0..<artistsInfo.count{
            if let artistController = self.storyboard?.instantiateViewControllerWithIdentifier("ArtistInfo") as? ArtistInfoViewController{
                
                let artist = NSEntityDescription.insertNewObjectForEntityForName(Artist.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Artist//Artist()//Artist(name: artistsInfo[index].name, biography: artistsInfo[index].news, image: artistsInfo[index].image)
                
                artist.name = artistsInfo[index].name
                artist.biography = artistsInfo[index].news
                artist.image = UIImageJPEGRepresentation(artistsInfo[index].image, 1.0)
                
                
                var songList = [Song]()
                var song: Song!
                
                switch index {
                case 0:
                    songList = [Song]()
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "Bloomdido"
                    song.album = "Bird And Diz"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "BirdAndDiz")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("Bloomdido", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "Scrapple From The Apple"
                    song.album = "Bird And Diz"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "BirdAndDiz")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("ScrappleFromTheApple", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    
                    artist.songlist = NSSet(array: songList)
                case 1:
                    songList = [Song]()
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "Don't Panic"
                    song.album = "Parachutes"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "Parachutes")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("DontPanic", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "Adventure Of A Lifetime"
                    song.album = "A Head Full Of Dreams"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "AHeadFullOfDreams")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("AdventureOfALifetime", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    artist.songlist = NSSet(array: songList)
                case 2:
                    songList = [Song]()
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "So It May Secretly Begin"
                    song.album = "Still Life(Talking)"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "StillLife")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("SoItMaySecretlyBegin", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: DataManager.managedObjectContext) as! Song
                    song.name = "Au Lait"
                    song.album = "Offramp"
                    song.artwork = UIImageJPEGRepresentation(UIImage(named: "Offramp")!, 1.0)
                    song.path = NSBundle.mainBundle().pathForResource("AuLait", ofType: "mp3")!
                    song.online = false
                    
                    songList.append(song)
                    
                    artist.songlist = NSSet(array: songList)
                default:
                    break
                }
                
                
                artistController.artistInfo = artist
                artistController.pageIndex = index
                //artistController.delegate = self
                
                
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
        PlayerManager.nextTrack(false)
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
    
    //MARK: - RemoteControls
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        
        switch event!.subtype {
        case .RemoteControlPlay:
            PlayerManager.playTrack(false)
            break
        case .RemoteControlPause:
            PlayerManager.pauseTrack(false)
            break
        case .RemoteControlNextTrack:
            PlayerManager.nextTrack(false)
            break
        case .RemoteControlPreviousTrack:
            PlayerManager.previousTrack(false)
            break
        default:
            break
        }
        
    }
  
    
    @IBAction func showDownload(sender: AnyObject) {
        performSegueWithIdentifier("downloadCenter", sender: self)
    }
    
    
    
    //MARK: - AudioPlayerStartedDelegate Deprecated
    
    /*
    
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
    
    func updateBlockedScreen() {
        let artwork = MPMediaItemArtwork(image: currentSong.artwork)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle : currentSong.name,
            MPMediaItemPropertyArtist : artistInfo.name,
            MPMediaItemPropertyArtwork : artwork,
            MPMediaItemPropertyPlaybackDuration : Float(audioPlayerDelegated!.duration),
            MPMediaItemPropertyAlbumTitle: currentSong.album,
            MPNowPlayingInfoPropertyPlaybackRate : 1.0
        ]    }*/
}

