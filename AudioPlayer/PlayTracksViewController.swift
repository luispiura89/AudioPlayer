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
    
    fileprivate static var testObj = Test()
    
    static func sharedTest() -> Test {
        return testObj
        
    }
    
    fileprivate override init() {
        
    }
}

protocol AudioPlayerStarted {
    func audioPlayerStarted(_ song: Song, songList: [Song], currentIndex: IndexPath, artistInfo: Artist)
    func setSongPlayedDelegate(_ songPlayed: SongPlayed)
    func setPlayerCurrentTime(_ currentTime: Float)
    func stopPlaying()
    func resumePlaying()
    func playTrack(_ playTrack: Bool)
    func pauseTrack(_ playTrack: Bool)
    func nextTrack(_ playTrack: Bool)
    func previousTrack(_ playTrack: Bool)
}

protocol SongPlayed {
    func setPlayerDuration(_ duration: Float)
    func setPlayerCurrentTime(_ currentTime: Float)
    func changPlayingStatus(_ status: Bool)
    func setCurrentPlayedSong(_ currentSong: Song)
}

class PlayTracksViewController: UIViewController, SongPlayed, URLSessionDelegate {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var donwloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var downloadTask : URLSessionDownloadTask!
    var remoteEvent: UIEvent!
    var didMotion = false
    var isDownloading = false
    
    var songList: [Song]!
    var currentSong: Song!
    var songIndex: IndexPath!
    var artist: Artist!
    var currentIndex: Int!
    
    var isPlaying = true{
        didSet{
            playButton.isSelected = !isPlaying
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        donwloadButton.isHidden = true
        deleteButton.isHidden = true
        currentIndex = songIndex.row
        updateUI()
        startSong()

        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        becomeFirstResponder()
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
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
                        
                        let downloadRequest = URLRequest(url: url)
                        let session = Foundation.URLSession(configuration: .default, delegate: self, delegateQueue: .main)
                        downloadTask = session.downloadTask(with: downloadRequest)
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
        
        artworkImageView.image = UIImage(data: currentSong.artwork! as Data)
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
                deleteButton.isHidden = false
                
                PlayerManager.currentSongData(data)
                PlayerManager.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
                PlayerManager.setSongPlayedDelegate(self)
            }else{
                if let url = currentSong.fileURL{
                    if !isDownloading{
                        isDownloading = true
                        
                        let downloadRequest = URLRequest(url: url)
                        let session = Foundation.URLSession(configuration: .default, delegate: self, delegateQueue: .main)
                        downloadTask = session.downloadTask(with: downloadRequest)
                        downloadTask.resume()
                    }
                }
            }
        }
        //delegate.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
        //delegate.setSongPlayedDelegate(self)
        
    }
    
    @IBAction func playPause(_ sender: AnyObject) {
        if isPlaying == true{
            isPlaying = false
            PlayerManager.stopPlaying()
        }else{
            isPlaying = true
            PlayerManager.resumePlaying()
        }
    }
    
    @IBAction func donwloadAction(_ sender: AnyObject) {
        donwloadButton.isHidden = true
        deleteButton.isHidden = false

        currentSong.save()
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        currentSong.data = nil
        donwloadButton.isHidden = false
        deleteButton.isHidden = true
        currentSong.save()
    }
    
    @IBAction func moveCurrentTime(_ sender: AnyObject) {
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
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    //MARK: - SongPlayedDelegate
    
    func setPlayerDuration(_ duration: Float) {
        currentTimeSlider.maximumValue = duration
    }
    
    func setPlayerCurrentTime(_ currentTime: Float) {
        currentTimeSlider.value = currentTime
    }
    
    func changPlayingStatus(_ status: Bool) {
        isPlaying = status
    }
    
    func setCurrentPlayedSong(_ currentSong: Song) {
        self.currentSong = currentSong
        updateUI()
    }
    
    //MARK: - RemoteControls
    override func remoteControlReceived(with event: UIEvent?) {
        //if let delegate = delegate{
            switch event!.subtype {
            case .remoteControlPlay:
                PlayerManager.playTrack(true)
                break
            case .remoteControlPause:
                PlayerManager.pauseTrack(true)
                break
            case .remoteControlNextTrack:
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
                                
                                let downloadRequest = URLRequest(url: url)
                                let session = Foundation.URLSession(configuration: .default, delegate: self, delegateQueue: .main)
                                downloadTask = session.downloadTask(with: downloadRequest)
                                downloadTask.resume()
                            }
                        }
                    }
                }
                break
            case .remoteControlPreviousTrack:
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
                                
                                let downloadRequest = URLRequest(url: url)
                                let session = Foundation.URLSession(configuration: .default, delegate: self, delegateQueue: .main)
                                downloadTask = session.downloadTask(with: downloadRequest)
                                downloadTask.resume()
                            }
                        }
                    }
                }
                break
            case .motionShake:
                print("aqui")
                break
            default:
                break
            }
        //}
        
    }
    
    //MARK: - URLSessionDelegate
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        
        if let data = try? Data(contentsOf: location) {
            if !didMotion{
                if let remoteEvent = remoteEvent{
                    switch remoteEvent.subtype {
                    case .remoteControlNextTrack:
                        PlayerManager.currentSongData(data)
                        PlayerManager.nextTrack(true)
                    case .remoteControlPreviousTrack:
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
                    donwloadButton.isHidden = false
                }
            }else{
                
                PlayerManager.currentSongData(data)
                PlayerManager.nextTrack(true)
            }
        }
        isDownloading = false
        
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error{
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Other functions
    
    
    func nextSongURL() -> URL?{
        var currentIndexNexSong = PlayerManager.currentIndex
        if !didMotion{
            if let remoteEvent = remoteEvent{
                switch remoteEvent.subtype {
                case .remoteControlNextTrack:
                    
                    
                    if currentIndexNexSong == songList.count - 1{
                        currentIndexNexSong = 0
                    }else{
                        currentIndexNexSong = currentIndexNexSong! + 1
                    }
                    
                case .remoteControlPreviousTrack:
                    
                    
                    if currentIndexNexSong == 0{
                        currentIndexNexSong = songList.count - 1
                    }else{
                        currentIndexNexSong = currentIndexNexSong! - 1
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
                    currentIndexNexSong = currentIndexNexSong! + 1
                }
            }else{
                return nil
            }
            
        }
        
        return PlayerManager.songList[currentIndexNexSong!].fileURL
    }
    
    func nextSongData() -> Data?{
        var currentIndexNexSong = PlayerManager.currentIndex
        if !didMotion{
            if let remoteEvent = remoteEvent{
                switch remoteEvent.subtype {
                case .remoteControlNextTrack:
                    
                    
                    if currentIndexNexSong == songList.count - 1{
                        currentIndexNexSong = 0
                    }else{
                        currentIndexNexSong = currentIndexNexSong! + 1
                    }
                    
                case .remoteControlPreviousTrack:
                    
                    
                    if currentIndexNexSong == 0{
                        currentIndexNexSong = songList.count - 1
                    }else{
                        currentIndexNexSong = currentIndexNexSong! - 1
                    }
                    
                default:
                    break
                }
            }
        }else{
            if currentIndexNexSong == songList.count - 1{
                currentIndexNexSong = 0
            }else{
                currentIndexNexSong = currentIndexNexSong! + 1
            }
        }
        
        return PlayerManager.songList[currentIndexNexSong!].data
    }
}
