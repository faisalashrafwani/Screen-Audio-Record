//
//  RecordViewController.swift
//  Screen Audio Record
//
//  Created by Umer on 17/08/22.
//


import UIKit
import AVFoundation
import Foundation
import Lottie

class RecordViewController:  UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var gotItButton: UIButton!
    
    @IBOutlet weak var starterParentView: UIView!
    @IBOutlet weak var starterView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var recordView: UIView!
    var counter = 0
    var timer = Timer()
    var lottieTimer: Timer?
    var starterLabel = 5

    @IBOutlet weak var starterLabelView: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var isFirstTime = true
   // var observations : [Observation] = []
    var observation = FlashObservation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // showAlert()
     
        animationView.isHidden = true
        counterLabel.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        actionButton.isEnabled = false
        actionButton.setTitle("Start Recording", for: .normal)
        setupRecorderSession()
       self.imageView.image = #imageLiteral(resourceName: "final_instruction3")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1800) {
          
            self.finishRecording(success: true)
        }
        
        actionButton.isHidden = true
        
//        starterView.translatesAutoresizingMaskIntoConstraints = false
//        starterView.layer.cornerRadius = starterView.bounds.width/2
//
//               starterView.layer.borderColor =  UIColor.black.cgColor
//               starterView.layer.borderWidth = 2
        makeCircle(view: starterView)
       
        
    }
    override func viewDidAppear(_ animated: Bool) {
        MainViewController.observations.removeAll()
   
    }
    @IBAction func ActionButtonClicked(_ sender: UIButton) {
        showAlert()
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.imageView.image = #imageLiteral(resourceName: "instruction2")
    }
    
    //TODO: SETUP ANIMATION
    private func setupAnimation() {
        animationView.contentMode = .scaleAspectFit
        Animation.loadedFrom(url: URL(string: "https://assets1.lottiefiles.com/datafiles/QeC7XD39x4C1CIj/data.json")!, closure: { [animationView] animation in
            self.animationView?.animation = animation
        }, animationCache: LRUAnimationCache.sharedCache)
    }
    
    private func startMonitoring() {
        audioRecorder?.isMeteringEnabled = true
        lottieTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [audioRecorder, weak self] (lottieTimer) in
            audioRecorder?.updateMeters()
            self?.updateAudioMeter(audioRecorder?.averagePower(forChannel: 0) ?? 0)
        })
    }
    
    private func updateAudioMeter(_ power: Float) {
        let level = max(0.2, CGFloat(power) + 50) / 2
        let progress = level/25
        
        animationView.currentFrame = 33*progress
    }
    
    deinit {
        lottieTimer?.invalidate()
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
                        // TODO: CREATING GESTURE RECOGNIZER
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gestureFired(_:)))
                        gestureRecognizer.numberOfTapsRequired = 1
                        gestureRecognizer.numberOfTouchesRequired = 2

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
//        if isFirstTime{
//            isFirstTime = false
//            self.imageView.image = #imageLiteral(resourceName: "start")
//            return
//        }
//        if audioRecorder == nil {
//           observation = FlashObservation()
//
//            startRecording()
//        } else {
//            finishRecording(success: true)
//        }
        
        
        //AudioServicesPlayAlertSound(SystemSoundID(1322))
        
      //  AudioServicesPlaySystemSound(SystemSoundID(1322))
        
        if  audioRecorder != nil && audioRecorder.isRecording {
            observation.metaData.append(EventTime(timeStamp: captureDateTime(), secondOfAudio: audioRecorder.currentTime))
            let url = Bundle.main.url(forResource: "beeeep", withExtension: "mp3")
            audioPlayer = try! AVAudioPlayer(contentsOf: url!)
            audioPlayer.play()
        }
      
    }
    
    // TODO: STARTS RECORDING VOICE
    func startRecording() {
        animationView.isHidden = false
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
            startMonitoring()
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
        let dialogMessage = UIAlertController(title: "Alert", message: "Once you stop recording, you cannot restart it, are you sure to stop?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Stop", style: .default, handler: { (action) -> Void in
           
            
            if self.audioRecorder == nil {
               
            } else {
              //  self.actionButton.setTitle("Start Recording", for: .normal)
        
                self.finishRecording(success: true)
                self.animationView.isHidden = true
                self.showResultAlert()
                
            }
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
    func showResultAlert(){
        let dialogMessage = UIAlertController(title: "Flash Monitor", message: "Number of times Flash recorded : \(observation.metaData.count) ", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
           
            self.navigationController?.popViewController(animated: true)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
      //  dialogMessage.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(dialogMessage, animated: true, completion: nil)
        }
        // Present alert message to user
       // self.present(dialogMessage, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        finishRecording(success: true)
    }
    
    
    @IBAction func gotItTapped(_ sender: UIButton) {
        starterParentView.isHidden = false
        self.imageView.isHidden = true
        gotItButton.isHidden = true
        
        starterLabelView.text = String(starterLabel)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.imageView.isHidden = true
            self.starterLabel = self.starterLabel - 1
            self.starterLabelView.text = String(self.starterLabel)
            
            if self.starterLabel == 0 && self.audioRecorder == nil {
                self.observation = FlashObservation()
              
                self.actionButton.setTitle("Stop Recording", for: .normal)
               // actionButton.backgroundColor = UIColor.red
              //  actionButton.tintColor = UIColor.red
                
                self.actionButton.isEnabled = true
                self.actionButton.isHidden = false
                self.gotItButton.isHidden = true
                self.counterLabel.isHidden = false
                self.setupAnimation()
                self.startRecording()
                self.starterParentView.isHidden = true
                timer.invalidate()
            }

//            if randomNumber == 10 {
//                timer.invalidate()
//            }
        }
        
        
        
        
//        animationView.play(completion: {_ in
//           // self.animationView.isHidden = true
//            self.imageView.isHidden = true
//
//            if self.audioRecorder == nil {
//                self.observation = FlashObservation()
//
//                self.actionButton.setTitle("Stop Recording", for: .normal)
//               // actionButton.backgroundColor = UIColor.red
//              //  actionButton.tintColor = UIColor.red
//
//                self.actionButton.isEnabled = true
//                self.actionButton.isHidden = false
//                self.gotItButton.isHidden = true
//                self.counterLabel.isHidden = false
//                self.setupAnimation()
//                self.startRecording()
//            }
      //  })
        
        
        
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
    
    func makeCircle (view: UIView) {
            view.clipsToBounds = true
            let height = view.frame.size.height
            let width = view.frame.size.width
            let newHeight = max(height, width) // use "max" if you want big circle

            var rectFrame = view.frame
            rectFrame.size.height = newHeight
            rectFrame.size.width = newHeight
            view.frame = rectFrame
            view.layer.cornerRadius = newHeight/2
        
         view.layer.borderColor =  UIColor.black.cgColor
        view.layer.borderWidth = 2
        
        //               starterView.layer.borderWidth = 2
      //  starterView.translatesAutoresizingMaskIntoConstraints = false
     //        starterView.layer.cornerRadius = starterView.bounds.width/2
     //
     //               starterView.layer.borderColor =  UIColor.black.cgColor
     //               starterView.layer.borderWidth = 2
        }
    
}

