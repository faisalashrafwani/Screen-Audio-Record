//
//  PlayRecordingsTableViewCell.swift
//  Screen Audio Record
//
//  Created by admin on 18/08/22.
//

import UIKit

class PlayRecordingsTableViewCell: UITableViewCell {

    @IBOutlet weak var SeqNoView: UIButton!
    @IBOutlet weak var startDateTimelbl: UILabel!
    @IBOutlet weak var endDateTimelbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    var callbackPlay: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        self.callbackPlay?()
    }
    
}
