//
//  PlayTracksViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import MediaPlayer

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

class PlayTracksViewController: UIViewController, SongPlayed {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    var songList: [Song]!
    var currentSong: Song!
    var songIndex: NSIndexPath!
    var artist: Artist!
    var delegate: AudioPlayerStarted!
    var currentIndex: Int!
    
    var isPlaying = true{
        didSet{
            playButton.selected = !isPlaying
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentIndex = songIndex.row
        updateUI()
        startSong()

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }

    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if let delegate = delegate{
            delegate.nextTrack(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(){
        
        artworkImageView.image = currentSong.artwork
        songNameLabel.text = currentSong.name
        songAlbumLabel.text = currentSong.album
        currentTimeSlider.value = 0
    }
    
    func startSong(){
        delegate.audioPlayerStarted(currentSong, songList: songList, currentIndex: songIndex, artistInfo: artist)
        delegate.setSongPlayedDelegate(self)
        
    }
    
    @IBAction func playPause(sender: AnyObject) {
        if isPlaying == true{
            isPlaying = false
            delegate.stopPlaying()
        }else{
            isPlaying = true
            delegate.resumePlaying()
        }
    }
    
    @IBAction func moveCurrentTime(sender: AnyObject) {
        delegate.setPlayerCurrentTime(currentTimeSlider.value)
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
        if let delegate = delegate{
            switch event!.subtype {
            case .RemoteControlPlay:
                delegate.playTrack(true)
                break
            case .RemoteControlPause:
                delegate.pauseTrack(true)
                break
            case .RemoteControlNextTrack:
                delegate.nextTrack(true)
                break
            case .RemoteControlPreviousTrack:
                delegate.previousTrack(true)
                break
            case .MotionShake:
                print("aqui")
                break
            default:
                break
            }
        }
        
    }
}
