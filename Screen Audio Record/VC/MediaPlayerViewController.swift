//
//  MediaPlayerViewController.swift
//  Screen Audio Record
//
//  Created by Faisal Ashraf Wani on 25/08/22.
//

import UIKit
import AVFoundation

class MediaPlayerViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var recordingNameLbl: UILabel!
    
    var position: Int = 0
    var recordList = [FlashObservation]()
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer.stop()
    }
    
    func configure() {
        let str = recordList[position].audioPath
        let url = URL(string: str!)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.delegate = self
            recordingNameLbl.text = str
            
            audioPlayer.play()
           
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    @IBAction func previousButtonAction(_ sender: Any) {
        if position > 0 {
            position = position - 1
            audioPlayer.stop()
            
            configure()
        }
    }
    

    @IBAction func playButtonAction(_ sender: Any) {
        if audioPlayer.isPlaying {
            playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            audioPlayer.stop()
        } else {
            audioPlayer.play()
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            
        }
    }
    
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        if position < (recordList.count - 1) {
            position = position + 1
            audioPlayer.stop()
            
            configure()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        audioPlayer.stop()
        
    }
}
























//            let str = self.recordingList[indexPath.row].audioPath
//            let url = URL(string: str!)
//            do {
//                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
//                try AVAudioSession.sharedInstance().setActive(true)
//
//                self.audioPlayer = try AVAudioPlayer(contentsOf: url!)
//
//                self.audioPlayer.play()
//
//            } catch {
//                print("inner \(error)")
//            }
