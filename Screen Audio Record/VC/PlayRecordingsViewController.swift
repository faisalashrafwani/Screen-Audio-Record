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
    
    var recordingList = [Observation]()
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.playRecordingsTableView.delegate = self
        self.playRecordingsTableView.dataSource = self
        self.playRecordingsTableView.register(UINib(nibName: "PlayRecordingsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        
        
        if let data = UserDefaults.standard.object(forKey: "recordingList") as? Data {
            let recordingData =  try! JSONDecoder().decode([Observation].self, from: data)
            recordingList = recordingData
        }
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
        
            cell.endDateTimelbl.text = "End Date: \(recordingList[indexPath.row].startDate!)"
            cell.startDateTimelbl.text = "Start Date: \(recordingList[indexPath.row].endDate!)"
            
//            cell.callbackPlay = {
//                let url = URL(string: self.recordingList[indexPath.row].audioPath ?? "")
//                self.audioPlayer = try! AVAudioPlayer(contentsOf: url!)
//                self.audioPlayer.play()
//            }
        cell.callbackPlay = {
            let str = self.recordingList[indexPath.row].audioPath
            let url = URL(string: str!)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url!)
                self.audioPlayer.play()
            } catch {
                print("inner \(error)")
            }
            
        }
        
//            cell.isUserInteractionEnabled = false
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
