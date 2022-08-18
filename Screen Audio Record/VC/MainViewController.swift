//
//  MainViewController.swift
//  Screen Audio Record
//
//  Created by Umer on 17/08/22.
//

import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var tapGesture: UIButton!
    
//    var observation = Observation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
//        var recordVC = RecordViewController()
//        navigationController?.pushViewController(recordVC, animated: true)
        
        var playRecordingsVC = PlayRecordingsViewController()
        navigationController?.pushViewController(playRecordingsVC, animated: true)
        
    }
    
}
