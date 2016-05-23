//
//  TrackListViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var artist: Artist!
    var selectedSongIndex: NSIndexPath!
    var delegate: AudioPlayerStarted!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "\(artist.name)'s Songs"
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if let delegate = delegate{
            delegate.nextTrack(false)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlayTracks"{
            if let vc = segue.destinationViewController as? PlayTracksViewController{
                vc.songList = artist.songList
                vc.currentSong = artist.songList[selectedSongIndex.row]
                vc.songIndex = selectedSongIndex
                vc.artist = artist
                vc.delegate = delegate
            }
        }
    }
    
    
    //MARK: TableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artist.songList.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell")!
        
        cell.textLabel?.text = artist.songList[indexPath.row].name
        cell.detailTextLabel?.text = "Album: \(artist.songList[indexPath.row].album)"
        cell.imageView?.image = artist.songList[indexPath.row].artwork
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedSongIndex = indexPath
        
        performSegueWithIdentifier("PlayTracks", sender: self)
    }
    
    //MARK: - RemoteControls
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let delegate = delegate{
            switch event!.subtype {
            case .RemoteControlPlay:
                delegate.playTrack(false)
                break
            case .RemoteControlPause:
                delegate.pauseTrack(false)
                break
            case .RemoteControlNextTrack:
                delegate.nextTrack(false)
                break
            case .RemoteControlPreviousTrack:
                delegate.previousTrack(false)
                break
            default:
                break
            }
        }
        
    }

}
