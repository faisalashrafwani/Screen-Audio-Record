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
    @IBOutlet weak var seekbarSlider: UISlider!
    
    
    var position: Int = 0
    var recordList = [FlashObservation]()
    var audioPlayer = AVAudioPlayer()
    lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackStatus))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        
        displayLink.frameInterval = 1
        displayLink.add(to: .current, forMode: .common)
        
        
        
        
        
        

        
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
            recordingNameLbl.text = "Recording\n\(recordList[position].metaData[position].timeStamp)"
            
            audioPlayer.play()
           
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        audioPlayer.stop()
        
    }
    
    func startUpdatingPlaybackStatus() {
        displayLink.add(to: .main, forMode: .common)
    }
    
    func stopUpdatingPlaybackStatus() {
        displayLink.invalidate()
    }
    
    @objc func updatePlaybackStatus() {
        let playbackProgress = Float(audioPlayer.currentTime / audioPlayer.duration)
        seekbarSlider.setValue(playbackProgress, animated: true)
        
        let normalizedTime = Float(self.audioPlayer.currentTime as! Double / (self.audioPlayer.duration as! Double) )

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
    
    @IBAction func didBeginDraggingSlider(_ sender: Any) {
        displayLink.isPaused = true
    }
    
    
    @IBAction func didEndDraggingSlider(_ sender: Any) {
        let newPosition = audioPlayer.duration * Double(seekbarSlider.value)
        audioPlayer.currentTime = newPosition

            displayLink.isPaused = false
    }
    
    
    
}
