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
    @IBOutlet weak var totalEventsView: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var playSavedRecordingButton: UIButton!
    
    @IBOutlet weak var instructionTV: UITextView!
    @IBOutlet weak var instructionParentView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var audioMin2: UILabel!
    @IBOutlet weak var timestamp2: UILabel!
    @IBOutlet weak var audioMin1: UILabel!
    @IBOutlet weak var timestamp1: UILabel!
    @IBOutlet weak var durationView: UILabel!
    @IBOutlet weak var endTimeView: UILabel!
    @IBOutlet weak var startTimeView: UILabel!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var starterParentView: UIView!
    @IBOutlet weak var starterView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var recordView: UIView!
    var counter = 0
    var timer = Timer()
    var lottieTimer: Timer?
    var starterLabel = 5
    var timeForActivity = 60
    
    @IBOutlet weak var starterLabelView: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadLogButton: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var isFirstTime = true
    // var observations : [Observation] = []
    var observation = FlashObservation()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // showAlert()
        
        
        dateFormatter.dateFormat = "E, d MMM yyyy HH: mm: ss Z"
        
        
        animationView.isHidden = true
        counterLabel.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        actionButton.isEnabled = false
        actionButton.layer.cornerRadius = 10
        actionButton.setTitle("Start Recording", for: .normal)
        setupRecorderSession()
        
        self.imageView.image = #imageLiteral(resourceName: "final_instruction7")
        
        
        
        
        actionButton.isHidden = true
        
        updateInstructionUI()
        
        //        starterView.translatesAutoresizingMaskIntoConstraints = false
        //        starterView.layer.cornerRadius = starterView.bounds.width/2
        //
        //               starterView.layer.borderColor =  UIColor.black.cgColor
        //               starterView.layer.borderWidth = 2
        makeCircle(view: starterView)
        
        addSwipeGesture(view: actionButton)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        MainViewController.observations.removeAll()
        
    }
    @IBAction func ActionButtonClicked(_ sender: UIButton) {
        showAlert()
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.imageView.image = #imageLiteral(resourceName: "instruction2")
        if  MainViewController.observations.count <= 0 {
            playSavedRecordingButton.isHidden = true
            
        } else {
            playSavedRecordingButton.isHidden = false
            
        }
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UIDevice.current.name)_\(captureDateTime).m4a")
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
    func playRecordingCompleted() {
        let url = Bundle.main.url(forResource: "recordedCompleted", withExtension: "mp3")
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
        if success == true {
            playRecordingCompleted()
        }else {
            
            playRecordingStopped()
        }
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
        self.animationView.isHidden = true
        self.updateSummaryUI()
        self.feedbackView.isHidden = false
        convertJsonToString(observation: observation)
        
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
                
                self.finishRecording(success: false)
                
                
                // self.showResultAlert()
                
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
        finishRecording(success: false)
    }
    
    
    @IBAction func gotItTapped(_ sender: UIButton) {
        starterParentView.isHidden = false
        self.imageView.isHidden = true
        //   gotItButton.isHidden = true
        instructionParentView.isHidden = true
        
        starterLabel = 5
        starterLabelView.text = String(starterLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + ( Double(UInt64(timeForActivity))*60)) {
            
            self.finishRecording(success: true)
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.imageView.isHidden = true
            self.starterLabel = self.starterLabel - 1
            self.starterLabelView.text = String(self.starterLabel)
            
            if self.starterLabel == 0 && self.audioRecorder == nil {
                self.observation = FlashObservation()
                
                self.actionButton.setTitle("Swipe to Stop  -->", for: .normal)
                self.actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
                
                // actionButton.backgroundColor = UIColor.red
                //  actionButton.tintColor = UIColor.red
                
                self.actionButton.isEnabled = true
                self.actionButton.isHidden = false
                //self.gotItButton.isHidden = true
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
    
    
    func addSwipeGesture(view : UIView){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        // leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        //view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        
        showAlert()
        
        //        if (sender.direction == .left) {
        //                print("Swipe Left")
        //                }
        //
        //        if (sender.direction == .right) {
        //            print("Swipe Right")
        //             }
    }
    
    
    func updateSummaryUI(){
        
        
        
        let dateFt = DateFormatter()
        
        dateFt.dateFormat = "HH:mm:ss"
        
        startTimeView.text = dateFt.string(from:dateFormatter.date(from: observation.startDate!)! )
        endTimeView.text = dateFt.string(from:dateFormatter.date(from: observation.endDate!)! )
        durationView.text = String(Int(observation.duration!))
        totalEventsView.text = String(observation.metaData.count)
        deviceNameLabel.text = UIDevice.current.name
        
        if (observation.metaData.count > 1){
            timestamp1.text = "Timestamp : \(dateFt.string(from:dateFormatter.date(from: observation.metaData[0].timeStamp)! ))"
            
            
            var time1 = secondToHourMinSec(seconds: Int(observation.metaData[0].secondOfAudio))
            
            audioMin1.text = "Seek Time : \(makeTimeString(hours: time1.0, minutes: time1.1, seconds: time1.2))"
            
            timestamp2.text = "Timestamp : \(dateFt.string(from:dateFormatter.date(from: observation.metaData[1].timeStamp)! ))"
            var time2 = secondToHourMinSec(seconds: Int(observation.metaData[1].secondOfAudio))
            
            audioMin2.text = "Seek Time : \(makeTimeString(hours: time2.0, minutes: time2.1, seconds: time2.2))"
        }
        
    }
    
    
    
    @IBAction func okButton(_ sender: UIButton) {
        feedbackView.isHidden = true
        instructionParentView.isHidden = false
        
        // self.navigationController?.popViewController(animated: true)
        
        if  MainViewController.observations.count <= 0 {
            playSavedRecordingButton.isHidden = true
            
        } else {
            playSavedRecordingButton.isHidden = false
            
        }
        
    }
    func  updateInstructionUI(){
        
        let bullet = "•  "
        
        var strings = [String]()
        strings.append("Activity will record your audio continuously for \(self.timeForActivity) minutes.")
        strings.append("Activity will autocomplete after \(self.timeForActivity) minutes or you can stop it anytime by tapping on the Stop button.")
        strings.append("Activity duration can be set by clicking the Clock Button above.")
        strings.append("This is a one time activity and cannot be restarted.")
        strings.append("When you see the Light Flash tap anywhere on the screen using 2 fingers to capture the timestamp. This will be followed by a beep sound to confirm your Tap was successful.")
        strings.append("Describe the nature of Light Flash verbally when you see the Light Flash.")
        strings.append("You will get the Activity summary once it is completed.")
        strings.append("Tap the Start button to start the Audio recording.")
        
        strings = strings.map { return bullet + $0 }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = UIFont.systemFont(ofSize: 20)
        attributes[.foregroundColor] = UIColor.darkGray
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
        attributes[.paragraphStyle] = paragraphStyle
        
        let string = strings.joined(separator: "\n\n")
        instructionTV.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        
    }
    @IBAction func timerButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Timer", message: "Please enter time in Minutes", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Time in Minutes"
            textField.keyboardType = .phonePad
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let userText = textField.text else { return
                
            }
            var text = textField.text
            self.timeForActivity = Int(userText) ?? 60
            self.updateInstructionUI()
            //print("User text: \(userText)")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        saveData()
    }
    func saveData(){
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let logFileName = url?.appendingPathComponent("file.text")
        
        
        FileManager.default.createFile(atPath: logFileName!.path, contents: nil, attributes: nil)
    }
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
    
    func convertJsonToString(observation : FlashObservation){
        
        do {
            //let data = try JSONEncoder().encode(observation)
            var data = observation.toString()
            
            
            data?.append(getDeviceDetails()!)
            data?.append(getTapLogs()!)
            
            
            
            // The JSON data is in bytes. Let's printit as a JSON string.
            if let jsonString =  data {
                let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log.txt")
                
                do {
                    try jsonString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("exception")
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
                print(jsonString)
                //sharedata()
            }
            
            
        } catch let err {
            print("Failed to encode JSON")
        }
    }
    
    func sharedata(){
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log.txt")
        
        
        let fileURL = NSURL(fileURLWithPath: filename.path)
        
        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()
        
        // Add the path of the file to the Array
        filesToShare.append(fileURL)
        // let text = "This is some text that I want to share."
        
        // set up activity view controller
        //  let textToShare = [ text ]
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems:filesToShare, applicationActivities: nil)
        
        
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect  = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0,height: 0)
        self.present(activityViewController, animated: true, completion: nil)
        // Show the share-view
        //elf.navigationController!.present(activityViewController, animated: true, completion: nil)
        
        
    }
    func getDeviceDetails()-> String? {
        let model = UIDevice.current.model
        let os = UIDevice.current.systemName
        let osVer = UIDevice.current.systemVersion
        let deviceName = UIDevice.current.name
        
        return "\n\n Device Details: \n\n Device Name: \(deviceName) \n\n Device Model : \(model) \n\n Device OS : \(os) \n\n Device OS Version: \(osVer) \n\n "
    }
    
    func getTapLogs () -> String? {
        
        let dateFt = DateFormatter()
        
        dateFt.dateFormat = "HH:mm:ss"
        
        var values: String = ""
        
        
        for index in 0 ..< observation.metaData.count {
            var time = secondToHourMinSec(seconds: Int(observation.metaData[index].secondOfAudio))
            
            values += "\(index + 1)\t\tTimestamp: \(dateFt.string(from:dateFormatter.date(from:observation.metaData[index].timeStamp)!))\t\tSeek time: \(makeTimeString(hours: time.0, minutes: time.1, seconds: time.2))\n\n"
        }
        
        
        return "\n\nTap Logs: \n\n\(values)"
    }
    
    @IBAction func downloadLogButtonTapped(_ sender: Any) {
        sharedata()
    }
    
    @IBAction func playSavedRecordingButtonTapped(_ sender: Any) {
        var playRecordingsVC = PlayRecordingsViewController()
        navigationController?.pushViewController(playRecordingsVC, animated: true)
        
    }
    
}
