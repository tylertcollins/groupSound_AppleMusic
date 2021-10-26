//
//  ViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/20/21.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    var tracks: [AppleMusicTrack] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        AppleAuthManager.shared.getUserToken { success in
            if success {
                AppleAuthManager.shared.fetchStoreFrontID() { result in
                    switch result {
                    case .success(let storeFrontID):
                        print(storeFrontID)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @IBAction func didTapLeftPlaybackControl(_ sender: Any) {
        AppleMusicAPI.shared.searchAppleMusic("Taylor Swift") { result in
            switch result {
            case .success(let tracks):
                self.tracks = tracks
                print(tracks.count)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func didTapCenterPlaybackControl(_ sender: Any) {
        var trackIDs: [String] = []
        for track in tracks {
            trackIDs.append(track.id)
        }
        PlaybackManager.shared.musicPlayer.setQueue(with: trackIDs)
        PlaybackManager.shared.musicPlayer.play()
    }
    
}

