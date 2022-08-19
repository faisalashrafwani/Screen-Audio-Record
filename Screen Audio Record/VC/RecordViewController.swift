//
//  RecordViewController.swift
//  Screen Audio Record
//
//  Created by Umer on 17/08/22.
//


import UIKit
import AVFoundation
import Foundation

class RecordViewController:  UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var recordView: UIView!
    var counter = 0
    var timer = Timer()

    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var isFirstTime = true
   // var observations : [Observation] = []
    var observation = Observation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // showAlert()
        UIApplication.shared.isIdleTimerDisabled = true
        actionButton.isEnabled = false
        actionButton.setTitle("Start Recording", for: .normal)
        setupRecorderSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1800) {
          
            self.finishRecording(success: true)
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        MainViewController.observations.removeAll()
    }
    @IBAction func ActionButtonClicked(_ sender: UIButton) {
        
        if audioRecorder == nil {
           observation = Observation()
          
            actionButton.setTitle("Stop Recording", for: .normal)
           // actionButton.backgroundColor = UIColor.red
          //  actionButton.tintColor = UIColor.red
            
            startRecording()
        } else {
            actionButton.setTitle("Start Recording", for: .normal)
          
            finishRecording(success: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.imageView.image = #imageLiteral(resourceName: "instruction2")
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
                        
                        
                        actionButton.isEnabled = true
//                        // TODO: CREATING GESTURE RECOGNIZER
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
//        if isFirstTime{
//            isFirstTime = false
//            self.imageView.image = #imageLiteral(resourceName: "start")
//            return
//        }
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
    
        self.imageView.image = #imageLiteral(resourceName: "recording_started")
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
        actionButton.isEnabled = false
       self.imageView.image = #imageLiteral(resourceName: "recording_stopped")
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
        //dateFormatter.timeZone = TimeZone(identifier: "UTC")
       // dateFormatter.locale = Locale(identifier: "en_US")
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
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
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

