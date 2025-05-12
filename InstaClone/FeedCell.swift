//
//  FeedCell.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 13.04.2025.
//

import UIKit
import Firebase

protocol FeedCellDelegate: AnyObject {
  func feedCellDidTapDelete(_ cell: FeedCell)
    func feedCell(_ cell: FeedCell, didTapLike currentStateIsLiked: Bool)
}

class FeedCell: UITableViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var documentLabel: UILabel!
    
    @IBOutlet weak var trashButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postImage.contentMode = .scaleAspectFit
        self.selectionStyle = .none
        
        
        
    }
    
    var isLiked = false {
           didSet {          // buton rengi / başlığı vb.
               likeButton.configuration?.title = isLiked ? "Liked" : "Like"
               likeButton.tintColor = isLiked ? .systemGray : .systemBlue
              // likeButton.isEnabled = !isLiked           // ikinci tıklamayı engelle
           }
       }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        
        // 1️⃣ Mevcut durumu delegate’e bildir
            delegate?.feedCell(self, didTapLike: isLiked)

            // 2️⃣ Yerel UI’yı hemen güncelle (optimistik)
            isLiked.toggle()      // true ↔︎ false
        
   
        
      //  let fireStoreDatabase = Firestore.firestore()
        
        // if let likeCount = Int(likeLabel.text!) {
            
          //  let likeStore = ["likes" : likeCount + 1] as [String : Any]
            
          //  fireStoreDatabase.collection("posts").document(documentLabel.text!).setData(likeStore, merge: true)
            
            
            
        
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        
        delegate?.feedCellDidTapDelete(self)
        
      
        
    }
    
}
