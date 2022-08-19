//
//  ShakeViewController.swift
//  Screen Audio Record
//
//  Created by Umer on 17/08/22.
//

import UIKit
import AVFoundation
import Foundation

class ShakeViewController:  UIViewController, AVAudioRecorderDelegate {
    var counter = 0
    var timer = Timer()

    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var recordView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var isFirstTime = true
   // var observations : [Observation] = []
    var observation = Observation()
    var permission = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // showAlert()
        UIApplication.shared.isIdleTimerDisabled = true
        becomeFirstResponder()
        setupRecorderSession()
        
        MainViewController.observations.removeAll()
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.imageView.image = #imageLiteral(resourceName: "instuction_shake")
        MainViewController.observations.removeAll()
      
    }
    override var canBecomeFirstResponder: Bool {
           return true
       }
       
       // TODO: HANDLES SHAKE GESTURES
       override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
           if permission == true {
               if audioRecorder == nil {
                   startRecording()
               } else {
                   finishRecording(success: true)
               }
           }
       }
       
    
    
    // TODO: SETTING UP RECORDING SESSION
    func setupRecorderSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options : [.defaultToSpeaker])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.permission = true
                        // TODO: CREATING GESTURE RECOGNIZER
//                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gestureFired(_:)))
//                        gestureRecognizer.numberOfTapsRequired = 1
//                        gestureRecognizer.numberOfTouchesRequired = 2
//
//                        // TODO: SETTING GESTURE RECOGNIZER TO FILE
//                        self.recordView.addGestureRecognizer(gestureRecognizer)
//                        self.recordView.isUserInteractionEnabled = true
                        
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
        if isFirstTime{
            isFirstTime = false
            self.imageView.image = #imageLiteral(resourceName: "start_shake")
            return
        }
        if audioRecorder == nil {
           observation = Observation()
            
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    // TODO: STARTS RECORDING VOICE
    func startRecording() {
        counterLabel.isHidden = false
        startCounter()
       self.imageView.image = #imageLiteral(resourceName: "recording_shake")
        let captureDateTime = captureDateTime()
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording \(captureDateTime).m4a")
        do{
            try observation.audioPath = audioFilename.absoluteString
         
        }catch {
            
        }
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
            
            //self.recordView.backgroundColor = UIColor.green
            
            print("Recording in progress...\n")
            print("Start Time: \(captureDateTime)\n")
            observation.startDate = captureDateTime
            
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
        if (timer != nil){
            timer.invalidate()
        }
        counterLabel.isHidden = true
        counterLabel.text = "00 : 00 : 00"
        if audioRecorder == nil || !audioRecorder.isRecording {
            return
        }
       self.imageView.image = #imageLiteral(resourceName: "stop_shake")
       // self.imageView.image = #imageLiteral(resourceName: "stop")
        let captureDateTime = captureDateTime()
        observation.duration = audioRecorder.currentTime
        audioRecorder.stop()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playRecordingStopped()
       // self.recordView.backgroundColor = UIColor.red
        print("End Time: \(captureDateTime)\n")
        observation.endDate = captureDateTime
        MainViewController.observations.append(observation)
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
        dateFormatter.dateFormat = "yyyy-MM-dd HH: mm: ssZ"
       // dateFormatter.timeZone = TimeZone(identifier: "UTC")
        //dateFormatter.locale = Locale(identifier: "en_US")
        return (dateFormatter.string(from: Date()))
    }
    
    func showAlert(){
        let dialogMessage = UIAlertController(title: "Welcome", message: "Would you like to start flash survey, please press continue to proceed", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(dialogMessage, animated: true, completion: nil)
        }
        // Present alert message to user
       // self.present(dialogMessage, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        finishRecording(success: true)
    }
    func startCounter(){
        counter = 0

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    // called every time interval from the timer
    @objc func timerAction() {
            counter += 1
        var time = secondToHourMinSec(seconds: counter)
        counterLabel.text = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
           // label.text = "\(counter)"
        }
    
    func secondToHourMinSec(seconds : Int) -> (Int, Int, Int){
        return ((seconds/3600),((seconds%3600)/60),((seconds%3600)%60))
        
    }
    func makeTimeString(hours : Int, minutes : Int, seconds :Int )-> String {
        
        var timeString = ""
        timeString += String(format : "%02d", hours)
        timeString += " : "
        timeString += String(format : "%02d", minutes)
        timeString += " : "
        timeString += String(format : "%02d", seconds)
    
         return timeString
    }
}

