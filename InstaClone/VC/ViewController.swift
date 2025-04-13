//
//  ViewController.swift
//  InstaClone
//
//  Created by Reyhan Nur Ünlü on 11.04.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    @IBAction func singInButtonClicked(_ sender: Any) {
        if emailTf.text != nil && passwordTf.text != nil {
            Auth.auth().signIn(withEmail: emailTf.text!, password: passwordTf.text!) { (autdata, error) in
                if error != nil {
                    self.makeAlert(title: "error", message: error?.localizedDescription ?? "error")
                }else{
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                }
            }
        }else{
            makeAlert(title: "error", message: "geçersiz kullanıcı adı ya da parola")
        }
        
    }
    
    @IBAction func singUpButtonClicked(_ sender: Any) {
        
        if emailTf.text != nil && passwordTf.text != nil {
            Auth.auth().createUser(withEmail: emailTf.text!, password: passwordTf.text!) { (authdata , error) in
                 if error != nil {
                     self.makeAlert(title: "Error", message: error?.localizedDescription ?? "")
                 }else{
                     self.performSegue(withIdentifier: "toFeed", sender: nil)
                 }
            }
            
        } else {
            makeAlert(title: "Error", message: "Mail veya parola boş olamaz" )
        }
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    
}

