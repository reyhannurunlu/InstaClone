//
//  FeedCell.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 13.04.2025.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
    }
    

}
