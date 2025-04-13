//
//  SettingsViewController.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 11.04.2025.
//

import UIKit
import FirebaseAuth
class SettingsViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            if let sceneDelegate = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive })?
                .delegate as? SceneDelegate {
                
                sceneDelegate.currentUserCheck()
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
}
