//
//  ArtistInfoViewController.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit


struct ArtistInfo {
    var image: UIImage
    var name: String
    var news: String
}

class ArtistInfoViewController: UIViewController {

    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var newArtistLabel: UILabel!
    
    var artistInfo: Artist!
    var pageIndex: Int!
    //var delegate: AudioPlayerStarted!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        // Do any additional setup after loading the view.
        artistImageView.image = UIImage(data: artistInfo.image! as Data)
        artistNameLabel.text = artistInfo.name
        newArtistLabel.text = artistInfo.biography
        
        artistImageView.layer.masksToBounds = true
        
        artistImageView.layer.cornerRadius = artistImageView.frame.width / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showTrackList(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowTrackList", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowTrackList"{
            if let vc = segue.destination as? TrackListViewController{
                vc.artist = artistInfo
            }
        }
    }
    

}
