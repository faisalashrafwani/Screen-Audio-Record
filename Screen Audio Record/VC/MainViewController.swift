//
//  MainViewController.swift
//  Screen Audio Record
//
//  Created by Umer on 17/08/22.
//

import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var recordedAudios: UIButton!
    @IBOutlet weak var tapGesture: UIButton!
    
    static var observations :[FlashObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if  MainViewController.observations.count <= 0 {
            recordedAudios.isEnabled = false
            
        }else {
            recordedAudios.isEnabled = true
        }
    }

    @IBAction func GestureTapped(_ sender: UIButton) {
        var gestureVC = TapGestureViewController()
        navigationController?.pushViewController(gestureVC, animated: true)
        
    }
    
    @IBAction func motionGestureTapped(_ sender: Any) {
        var shakeVC = ShakeViewController()
        navigationController?.pushViewController(shakeVC, animated: true)
    }
    
    
    
    @IBAction func recordTapped(_ sender: UIButton) {
        var recordVC = RecordViewController()
        navigationController?.pushViewController(recordVC, animated: true)
        
      
        
    }
    @IBAction func recordedAudiosTapped(_ sender: Any) {
        var playRecordingsVC = PlayRecordingsViewController()
        navigationController?.pushViewController(playRecordingsVC, animated: true)
    }
    
}
