//
//  MeetingCell.swift
//  AmbulanceApp
//
//  Created by user166574 on 17/02/2020.
//

import UIKit

class MeetingCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var meetingSubjectLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
         actionBlock?()
    }
    
    
    var actionBlock: (() -> Void)? = nil
}
