//
//  PlayTracksViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class Test: NSObject {
    
    private static var testObj = Test()
    
    static func sharedTest() -> Test {
        return testObj
        
    }
    
    private override init() {
        
    }
}

protocol AudioPlayerStarted {
    func audioPlayerStarted(song: Song, songList: [Song], currentIndex: NSIndexPath, artistInfo: Artist)
    func setSongPlayedDelegate(songPlayed: SongPlayed)
    func setPlayerCurrentTime(currentTime: Float)
    func stopPlaying()
    func resumePlaying()
    func playTrack(playTrack: Bool)
    func pauseTrack(playTrack: Bool)
    func nextTrack(playTrack: Bool)
    func previousTrack(playTrack: Bool)
}

protocol SongPlayed {
    func setPlayerDuration(duration: Float)
    func setPlayerCurrentTime(currentTime: Float)
    func changPlayingStatus(status: Bool)
    func setCurrentPlayedSong(currentSong: Song)
}

class PlayTracksViewController: UIViewController, SongPlayed, NSURLSessionDelegate {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var donwloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var downloadTask : NSURLSessionDownloadTask!
    var remoteEvent: UIEvent!
    var didMotion = false
    var isDownloading = false
    
    var songList: [Song]!
    var currentSong: Song!
    var songIndex: NSIndexPath!
    var artist: Artist!
    var currentIndex: Int!
    
    var isPlaying = true{
        didSet{
            playButton.selected = !isPlaying
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        donwloadButton.hidden = true
        deleteButton.hidden = true
        currentIndex = songIndex.row
        updateUI()
        startSong()

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }

    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if !currentSong.online{
            PlayerManager.nextTrack(true)
        }else{
            didMotion = true
            if let url = nextSongURL(){
                if nextSongData() != nil{
                    PlayerManager.nextTrack(true)
                }else{
                    if !isDownloading{
                        isDownloading = true
                        let downloadRequest = NSMutableURLRequest(URL: url)
                        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration() , delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                        downloadTask = session.downloadTaskWithRequest(downloadRequest)
                        downloadTask.resume()
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(){
        
        artworkImageView.image = UIImage(data: currentSong.artwork!)
        songNameLabel.text = currentSong.name
        songAlbumLabel.text = currentSong.album
        currentTimeSlider.value = 0
    }
    
    func startSong(){
        if !currentSong.online{
            PlayerManager.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
            PlayerManager.setSongPlayedDelegate(self)
        }else{
            if let data = currentSong.data{
                deleteButton.hidden = false
                
                PlayerManager.currentSongData(data)
                PlayerManager.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
                PlayerManager.setSongPlayedDelegate(self)
            }else{
                if let URL = currentSong.fileURL{
                    if !isDownloading{
                        isDownloading = true
                        let downloadRequest = NSMutableURLRequest(URL: URL)
                        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration() , delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                        downloadTask = session.downloadTaskWithRequest(downloadRequest)
                        downloadTask.resume()
                    }
                }
            }
        }
        //delegate.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
        //delegate.setSongPlayedDelegate(self)
        
    }
    
    @IBAction func playPause(sender: AnyObject) {
        if isPlaying == true{
            isPlaying = false
            PlayerManager.stopPlaying()
        }else{
            isPlaying = true
            PlayerManager.resumePlaying()
        }
    }
    
    @IBAction func donwloadAction(sender: AnyObject) {
        donwloadButton.hidden = true
        deleteButton.hidden = false

        currentSong.save()
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        currentSong.data = nil
        donwloadButton.hidden = false
        deleteButton.hidden = true
        currentSong.save()
    }
    
    @IBAction func moveCurrentTime(sender: AnyObject) {
        PlayerManager.setPlayerCurrentTime(currentTimeSlider.value)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: - SongPlayedDelegate
    
    func setPlayerDuration(duration: Float) {
        currentTimeSlider.maximumValue = duration
    }
    
    func setPlayerCurrentTime(currentTime: Float) {
        currentTimeSlider.value = currentTime
    }
    
    func changPlayingStatus(status: Bool) {
        isPlaying = status
    }
    
    func setCurrentPlayedSong(currentSong: Song) {
        self.currentSong = currentSong
        updateUI()
    }
    
    //MARK: - RemoteControls
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        //if let delegate = delegate{
            switch event!.subtype {
            case .RemoteControlPlay:
                PlayerManager.playTrack(true)
                break
            case .RemoteControlPause:
                PlayerManager.pauseTrack(true)
                break
            case .RemoteControlNextTrack:
                remoteEvent = event
                if !currentSong.online{
                    PlayerManager.nextTrack(true)
                }else{
                    if let url = nextSongURL(){
                        if nextSongData() != nil{
                            PlayerManager.nextTrack(true)
                        }else{
                            if !isDownloading{
                                isDownloading = true
                                let downloadRequest = NSMutableURLRequest(URL: url)
                                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration() , delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                                downloadTask = session.downloadTaskWithRequest(downloadRequest)
                                downloadTask.resume()
                            }
                        }
                    }
                }
                break
            case .RemoteControlPreviousTrack:
                remoteEvent = event
                if !currentSong.online{
                    PlayerManager.previousTrack(true)
                }else{
                    if let url = nextSongURL(){
                        if nextSongData() != nil{
                            PlayerManager.previousTrack(true)
                        }else{
                            if !isDownloading{
                                isDownloading = true
                                let downloadRequest = NSMutableURLRequest(URL: url)
                                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration() , delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                                downloadTask = session.downloadTaskWithRequest(downloadRequest)
                                downloadTask.resume()
                            }
                        }
                    }
                }
                break
            case .MotionShake:
                print("aqui")
                break
            default:
                break
            }
        //}
        
    }
    
    //MARK: - URLSessionDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if let data = NSData(contentsOfURL: location) {
            if !didMotion{
                if let remoteEvent = remoteEvent{
                    switch remoteEvent.subtype {
                    case .RemoteControlNextTrack:
                        PlayerManager.currentSongData(data)
                        PlayerManager.nextTrack(true)
                    case .RemoteControlPreviousTrack:
                        PlayerManager.currentSongData(data)
                        PlayerManager.previousTrack(true)
                    default:
                        break
                    }
                }else{
                    currentSong.data = data
                    PlayerManager.currentSongData(data)
                    PlayerManager.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
                    PlayerManager.setSongPlayedDelegate(self)
                    donwloadButton.hidden = false
                }
            }else{
                
                PlayerManager.currentSongData(data)
                PlayerManager.nextTrack(true)
            }
        }
        isDownloading = false
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error{
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Other functions
    
    
    func nextSongURL() -> NSURL?{
        var currentIndexNexSong = PlayerManager.currentIndex
        if !didMotion{
            if let remoteEvent = remoteEvent{
                switch remoteEvent.subtype {
                case .RemoteControlNextTrack:
                    
                    
                    if currentIndexNexSong == songList.count - 1{
                        currentIndexNexSong = 0
                    }else{
                        currentIndexNexSong = currentIndexNexSong + 1
                    }
                    
                case .RemoteControlPreviousTrack:
                    
                    
                    if currentIndexNexSong == 0{
                        currentIndexNexSong = songList.count - 1
                    }else{
                        currentIndexNexSong = currentIndexNexSong - 1
                    }
                    
                default:
                    break
                }
            }
        }else{
            if currentIndexNexSong != nil{
                if currentIndexNexSong == songList.count - 1{
                    currentIndexNexSong = 0
                }else{
                    currentIndexNexSong = currentIndexNexSong + 1
                }
            }else{
                return nil
            }
            
        }
        
        return PlayerManager.songList[currentIndexNexSong].fileURL
    }
    
    func nextSongData() -> NSData?{
        var currentIndexNexSong = PlayerManager.currentIndex
        if !didMotion{
            if let remoteEvent = remoteEvent{
                switch remoteEvent.subtype {
                case .RemoteControlNextTrack:
                    
                    
                    if currentIndexNexSong == songList.count - 1{
                        currentIndexNexSong = 0
                    }else{
                        currentIndexNexSong = currentIndexNexSong + 1
                    }
                    
                case .RemoteControlPreviousTrack:
                    
                    
                    if currentIndexNexSong == 0{
                        currentIndexNexSong = songList.count - 1
                    }else{
                        currentIndexNexSong = currentIndexNexSong - 1
                    }
                    
                default:
                    break
                }
            }
        }else{
            if currentIndexNexSong == songList.count - 1{
                currentIndexNexSong = 0
            }else{
                currentIndexNexSong = currentIndexNexSong + 1
            }
        }
        
        return PlayerManager.songList[currentIndexNexSong].data
    }
}
