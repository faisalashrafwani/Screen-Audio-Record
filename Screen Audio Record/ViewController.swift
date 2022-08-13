//
//  ViewController.swift
//  Screen Audio Record
//
//  Created by admin on 13/08/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordView: UIView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorderSession()
        
    }
    
    // TODO: SETTING UP RECORDING SESSION
    func setupRecorderSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        // TODO: CREATING GESTURE RECOGNIZER
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gestureFired(_:)))
                        gestureRecognizer.numberOfTapsRequired = 1
                        gestureRecognizer.numberOfTouchesRequired = 1
                        
                        // TODO: SETTING GESTURE RECOGNIZER TO FILE
                        self.recordView.addGestureRecognizer(gestureRecognizer)
                        self.recordView.isUserInteractionEnabled = true
                        
                    } else {
                        print("No Permission Granted")
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    // TODO: HANDLES SCREEN SINGLE TAP GESTURES
    @objc func gestureFired(_ gesture: UITapGestureRecognizer) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    // TODO: STARTS RECORDING VOICE
    func startRecording() {
        let captureDateTime = captureDateTime()
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording \(captureDateTime).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            playRecordingNow()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            
            // TODO: OFFSET TIME
            let timeOffset = audioRecorder.deviceCurrentTime + 1.0
            
            // TODO: RECORDS VOICE
            audioRecorder.record(atTime: timeOffset) //DELAYS RECORDING BY 1 SECOND SO THAT VERBAL INSTRUCTIONS AREN'T RECORDED.
            
            self.recordView.backgroundColor = UIColor.green
            
            print("Recording in progress...\n")
            print("Start Time: \(captureDateTime)\n")
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    // TODO: VERBAL GUIDE RECORDING NOW
    func playRecordingNow() {
        let url = Bundle.main.url(forResource: "recordingNow", withExtension: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer.play()
    }
    // TODO: VERBAL GUIDE RECORDING STOPPED
    func playRecordingStopped() {
        let url = Bundle.main.url(forResource: "recordingStopped", withExtension: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer.play()
    }
    
    // TODO: STOPS RECORDING
    func finishRecording(success: Bool) {
        let captureDateTime = captureDateTime()
        audioRecorder.stop()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playRecordingStopped()
        self.recordView.backgroundColor = UIColor.red
        print("End Time: \(captureDateTime)\n")
        audioRecorder = nil
        
        if success {
            print("Recording success\n")
        } else {
            print("recording failed.")
        }
    }
    
    // TODO: METHOD USED IF INTERRUPTIONS STOP RECORDING
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    // TODO: RETURNS PATH FOR SAVING FILE
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        //PRINTS PATH FOR SAVED FILES
        print(paths)
        return paths[0]
    }
    
    // TODO: CAPTURES DATE AND TIME
    func captureDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH: mm: ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        return (dateFormatter.string(from: Date()))
    }
    
    
}

