//
//  FeedViewController.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 11.04.2025.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedCellDelegate{
    func feedCell(_ cell: FeedCell, didTapLike currentStateIsLiked: Bool) {
            currentStateIsLiked ? unlike(cell) : like(cell)
        }
    
   
    

    
    
    @IBOutlet weak var tableView: UITableView!
    
    var likedByArray = [[String]]()
    var didILike    = [Bool]()
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIdArray = [String]()
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 356
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getFromDataFirestore()
        
       
        
    }
    
    
    func getFromDataFirestore(){
        
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("posts").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                    self.likedByArray.removeAll()
                    self.didILike.removeAll()
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.userCommentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        
                        if let postedBy = document.get("postedBy") as? String {
                            self.userEmailArray.append(postedBy)
                        }
                        
                        if let postComment = document.get("postComment") as? String {
                            self.userCommentArray.append(postComment)
                        }
                        
                        if let likes = document.get("likes") as? Int {
                            self.likeArray.append(likes)
                        }
                        
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.userImageArray.append(imageUrl)
                        }
                        let likedBy = document.get("likedBy") as? [String] ?? []
                        self.likedByArray.append(likedBy)
                        if let uid = Auth.auth().currentUser?.uid {
                            self.didILike.append(likedBy.contains(uid))
                        } else {
                            self.didILike.append(false)
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
                
            }
        
        
            
        }
    
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userEmailArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
            
            cell.delegate = self
        
            // cell.postImage.image = UIImage(named: "select")
            cell.likeLabel.text =  String(likeArray[indexPath.row])
            cell.commentLabel.text = userCommentArray[indexPath.row]
            cell.usernameLabel.text = userEmailArray[indexPath.row]
            cell.documentLabel.text = documentIdArray[indexPath.row]
            let url = URL(string: userImageArray[indexPath.row])
            cell.postImage.kf.setImage(with: url)
            cell.isLiked = didILike[indexPath.row]
            
            let currentUserEmail = Auth.auth().currentUser?.email
                let isOwner          = userEmailArray[indexPath.row] == currentUserEmail

                cell.trashButton.isHidden = !isOwner

            
            return cell
        }
        
    func feedCellDidTapDelete(_ cell: FeedCell) {
      // ❶ IndexPath’i bul
      guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let imageUrlToDelete = userImageArray[indexPath.row]
        let docID            = documentIdArray[indexPath.row]

        showDeleteAlert(docID: docID,
                        imageUrl: imageUrlToDelete,
                        indexPath: indexPath)
    }
    
    private func deletePost(docID: String,
                            imageUrl: String,
                            indexPath: IndexPath) {

        // 1️⃣ Firestore dokümanını sil
        let posts = Firestore.firestore().collection("posts")
        posts.document(docID).delete { [weak self] error in
            guard let self = self else { return }

            if let error {
                print("Firestore delete error:", error)
                return
            }

            // 2️⃣ Storage’daki resmi SAKLANAN URL ile sil
            Storage.storage()
                .reference(forURL: imageUrl)
                .delete { err in
                    if let err { print("Storage delete error:", err) }
                }

           
            // 3️⃣ Tablodan satırı hemen kaldır (isteğe bağlı)
            //self.tableView.deleteRows(at: [indexPath], with: .automatic)
            // Dizileri ELLE güncellemene gerek yok — snapshotListener tetiklenecek.
        }
    }
    
    private func showDeleteAlert(docID: String,
                                 imageUrl: String,
                                 indexPath: IndexPath) {

        let alert = UIAlertController(
            title: "Silme İşlemi",
            message: "Gönderinizi silmek üzeresiniz. Emin misiniz?",
            preferredStyle: .alert)

        // ① Sil onayı
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { _ in
            self.deletePost(docID: docID,
                            imageUrl: imageUrl,
                            indexPath: indexPath)
        })

        // ② Vazgeç
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alert, animated: true)
    }
    
    func like(_ cell: FeedCell) {

        guard let indexPath = tableView.indexPath(for: cell),
              let uid = Auth.auth().currentUser?.uid else { return }

        let docID   = documentIdArray[indexPath.row]
        let docRef  = Firestore.firestore().collection("posts").document(docID)

        Firestore.firestore().runTransaction({ (txn, errPtr) -> Any? in
            let snap: DocumentSnapshot
            do {
                snap = try txn.getDocument(docRef)
            } catch let err as NSError {
                errPtr?.pointee = err
                return nil
            }

            var likes   = snap.get("likes") as? Int ?? 0
            var likedBy = snap.get("likedBy") as? [String] ?? []

            // Eğer kullanıcı zaten beğendiyse iptal
            if likedBy.contains(uid) { return nil }

            // Güncelle
            likes   += 1
            likedBy.append(uid)

            txn.updateData(["likes": likes,
                            "likedBy": likedBy], forDocument: docRef)
            return likes
        }) { [weak self] (_, error) in
            guard error == nil else {
                print("Like txn error:", error!)
                return
            }
            // UI’yi yerel olarak güncelle
            self?.likeArray[indexPath.row] += 1
            self?.didILike[indexPath.row]   = true
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func unlike(_ cell: FeedCell) {
        let (docRef, indexPath, uid, _) = context(for: cell)

        Firestore.firestore().runTransaction({ txn, errPtr -> Any? in
            // ---------- 1) Dokümanı güvenle al ----------
            let snap: DocumentSnapshot
            do {
                snap = try txn.getDocument(docRef)      // ❗️ try
            } catch {
                errPtr?.pointee = error as NSError      // hata geri yolla
                return nil
            }

            // ---------- 2) Alanları oku ----------
            guard var likes   = snap.data()?["likes"]   as? Int,
                  var likedBy = snap.data()?["likedBy"] as? [String] else {
                return nil
            }

            // ---------- 3) Mantık ----------
            if !likedBy.contains(uid) { return nil }    // zaten unlike
            likes   = max(likes - 1, 0)
            likedBy.removeAll { $0 == uid }

            txn.updateData([
                "likes"  : likes,
                "likedBy": likedBy
            ], forDocument: docRef)

            return nil
        }) { [weak self] _, error in
            guard error == nil, let self else { return }

            // UI güncelle
            likeArray[indexPath.row] = max(likeArray[indexPath.row] - 1, 0)
            didILike[indexPath.row]  = false
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }


  }
extension FeedViewController {

    /// İlgili hücre için docRef ve indexPath döner
    func context(for cell: FeedCell) -> (DocumentReference, IndexPath, String, String) {
        guard let indexPath = tableView.indexPath(for: cell),
              let uid       = Auth.auth().currentUser?.uid else {
            fatalError("Context resolve error")
        }
        let docID  = documentIdArray[indexPath.row]
        let ref    = Firestore.firestore().collection("posts").document(docID)
        return (ref, indexPath, uid, docID)
    }
}

