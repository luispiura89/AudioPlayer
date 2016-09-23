//
//  OnlineTracksViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import CoreData

class OnlineTracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var songsTableView: UITableView!
    
    var artists = [Artist](){
        didSet{
            songsTableView.reloadData()
        }
    }
    var selectedIndex: NSIndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadArtists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            if segue.identifier == "playOnline"{
                if let vc = segue.destinationViewController as? PlayTracksViewController{
                    let artistSongs = artists[selectedIndex.section].songlist?.allObjects as? [Song]
                    vc.songList = artistSongs
                    vc.currentSong = artistSongs![selectedIndex.row]
                    vc.songIndex = selectedIndex
                    vc.artist = artists[selectedIndex.section]
                }
            }
        

    }
    
    
    //MARK: - TableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return artists.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let songList = artists[section].songlist{
            return songList.count
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell")!
        if let songList = artists[indexPath.section].songlist{
            if let songs = songList.allObjects as? [Song]{
                let song = songs[indexPath.row]
                cell.textLabel?.text = song.name
                cell.detailTextLabel?.text = song.album
                cell.imageView?.image = UIImage(data: song.artwork!)
                /*if let artwork = song.artwork{
                    cell.imageView?.image = UIImage(data: artwork)
                }else{
                    if let image = artists[indexPath.section].image{
                    cell.imageView?.image = UIImage(data: image)
                    }
                }*/
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! ArtistHeaderTableViewCell
        
        
        let artist = artists[section]
        headerCell.artist = artist
        artist.downloadImageIfNeeded { (image) in
            headerCell.artistImage.image = image
            //self.songsTableView.reloadData()
        }
        
        let containerView = UIView(frame:headerCell.frame)
        containerView.addSubview(headerCell)
        return containerView
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        self.performSegueWithIdentifier("playOnline", sender: self)
    }
    
    func loadArtists(){
        
        let query = Query(className: Artist.ClassName)
        if let res = query.find() as? [Artist]{
            if res.count == 0{
                
                let artist = NSEntityDescription.insertNewObjectForEntityForName(Artist.ClassName, inManagedObjectContext: SaveManager.managedObjectContext) as! Artist
                
                artist.name = "Jorge Drexler"
                artist.biography = "Jorge Drexler es un cantautor uruguayo, ganador del premio Óscar a Mejor canción original. Además de músico y compositor es médico."
                artist.image = UIImageJPEGRepresentation(UIImage(named: "drexler")!, 1.0)
                
                var songs = [Song]()
                var song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: SaveManager.managedObjectContext) as! Song
                
                song.name = "Sea"
                song.album = "Sea"
                song.artwork = UIImageJPEGRepresentation(UIImage(named: "sea")!, 1.0)
                song.path = "http://images.amplified.com/FLVStream/Catalog/1a3908d2-7295-4613-9092-679b5162962c/Product/17c80956-80ed-4798-8cfd-7da65eb05669/724381049754_002_128_0003_102.mp3"
                song.online = true
                
                songs.append(song)
                
                song = NSEntityDescription.insertNewObjectForEntityForName(Song.ClassName, inManagedObjectContext: SaveManager.managedObjectContext) as! Song
                
                song.name = "Polvo de Estrellas"
                song.album = "Eco"
                song.artwork = UIImageJPEGRepresentation(UIImage(named: "eco")!, 1.0)
                song.path = "http://images.amplified.com/FLVStream/Catalog/1a3908d2-7295-4613-9092-679b5162962c/Product/b1b8126a-c64b-4643-85ed-d5fb084f08f4/825646222223_007_128_0001_102.mp3"
                song.online = true
                
                songs.append(song)
                artist.songlist = NSSet(array: songs)
                
                artist.save()
                
                artists.append(artist)
                

            }
        }
        
        
        
        
        let query2 = Query(className: Artist.ClassName)
        if let res2 = query2.find() as? [Artist]{
            for i in 0..<res2.count{
                let songs = res2[i].songlist?.allObjects as? [Song]
                for song in songs!{
                    song.online = true
                }
            }
            artists = res2
        }
        
        
    }

}
