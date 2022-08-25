//
//  PlayRecordingsViewController.swift
//  Screen Audio Record
//
//  Created by admin on 18/08/22.
//

import UIKit
import AVFoundation

class PlayRecordingsViewController: UIViewController {
    @IBOutlet weak var playRecordingsTableView: UITableView!
    
    var recordingList = [FlashObservation]()
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.playRecordingsTableView.delegate = self
        self.playRecordingsTableView.dataSource = self
        self.playRecordingsTableView.register(UINib(nibName: "PlayRecordingsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        
        
//        if let data = UserDefaults.standard.object(forKey: "recordingList") as? Data {
//            let recordingData =  try! JSONDecoder().decode([Observation].self, from: data)
//            recordingList = recordingData
//        }
        recordingList =  MainViewController.observations
    }


}

extension PlayRecordingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlayRecordingsTableViewCell
        
            cell.endDateTimelbl.text = "End Timestamp: \(recordingList[indexPath.row].endDate!)"
            cell.startDateTimelbl.text = "Start Timestamp: \(recordingList[indexPath.row].startDate!)"
        cell.SeqNoView.setTitle(String(indexPath.row + 1), for: .normal)
        
//        if recordingList[indexPath.row].metaData == nil {
//            cell.SeqNoView.setTitle(String(indexPath.row + 1), for: .normal)
//        }else {
//            cell.SeqNoView.setTitle(String(recordingList[indexPath.row].metaData.count), for: .normal)
//        }
                
        cell.callbackPlay = {
            
            let mediaPlayerVC = MediaPlayerViewController()
            
            mediaPlayerVC.recordList = self.recordingList
            mediaPlayerVC.position = indexPath.row
//            self.navigationController?.pushViewController(mediaPlayerVC, animated: true)
            self.present(mediaPlayerVC, animated: true)
            
            
        }
        
//            cell.isUserInteractionEnabled = false
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if  audioPlayer.isPlaying{
            audioPlayer.stop()
          
        }
    }
    
}
