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
    var selectedSongIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let artistName = artist.name{
            self.title = "\(artistName)'s Songs"
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        becomeFirstResponder()
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        //if let delegate = delegate{
            PlayerManager.nextTrack(false)
        //}
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlayTracks"{
            if let vc = segue.destination as? PlayTracksViewController{
                let artistSongs = artist.songlist?.allObjects as? [Song]
                vc.songList = artistSongs
                vc.currentSong = artistSongs![selectedSongIndex.row]
                vc.songIndex = selectedSongIndex
                vc.artist = artist
            }
        }
    }
    
    
    //MARK: TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let artistSongs = artist.songlist?.allObjects as? [Song]
        return artistSongs!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell")!
        
        let artistSongs = artist.songlist?.allObjects as? [Song]
        
        cell.textLabel?.text = artistSongs![indexPath.row].name
        cell.detailTextLabel?.text = "Album: \(artistSongs![indexPath.row].album!)"
        cell.imageView?.image = UIImage(data: artistSongs![indexPath.row].artwork! as Data)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSongIndex = indexPath
        
        performSegue(withIdentifier: "PlayTracks", sender: self)
    }
    
    //MARK: - RemoteControls
    override func remoteControlReceived(with event: UIEvent?) {
        //if let delegate = delegate{
            switch event!.subtype {
            case .remoteControlPlay:
                PlayerManager.playTrack(false)
                break
            case .remoteControlPause:
                PlayerManager.pauseTrack(false)
                break
            case .remoteControlNextTrack:
                PlayerManager.nextTrack(false)
                break
            case .remoteControlPreviousTrack:
                PlayerManager.previousTrack(false)
                break
            default:
                break
            }
        //}
        
    }

}
