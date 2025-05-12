//
//  UploadViewController.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 11.04.2025.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var buttonUpload: UIButton!
    @IBOutlet weak var commentTf: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        image.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(recognizer)

    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.editedImage] as? UIImage
               self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(title:String , message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

    
    
    @IBAction func uploadButton(_ sender: Any) {
        
        activityIndicator.startAnimating()
        buttonUpload.isEnabled = false
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı giriş yapmamış!")
            return
        }
        
        let alert = UIAlertController(title: "Gönderi işlemi", message: "Gönderinizi paylaşmak üzeresiniz,emin misiniz", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Vazgeç", style: UIAlertAction.Style.default)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) { UIAlertAction in

            self.activityIndicator.startAnimating()
            self.buttonUpload.isEnabled = false
            
        // Storage referansını oluştur
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        // Klasör ismini UID'ye göre oluştur
        let mediaFolder = storageReference.child("\(userId)/media")
        
            if let data = self.image.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                DispatchQueue.main.async {
                      self.activityIndicator.stopAnimating()
                      self.buttonUpload.isEnabled = true
                if error != nil {
                    self.makeAlert(title: "error", message: error?.localizedDescription ?? "error")
                    print("Yükleme hatası: \(error?.localizedDescription ?? "error")")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            let firestoreDataBase = Firestore.firestore()
                            
                            var firestoreReference : DocumentReference? = nil
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commentTf.text!,"date" : FieldValue.serverTimestamp(), "likes" : 0,  "likedBy": []  ] as [String : Any]
                            
                            firestoreReference = firestoreDataBase.collection("posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil{
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    self.image.image = UIImage(named: "select")
                                    self.commentTf.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                        }
                    }
                  }
                }
            }
        }
      }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
}
