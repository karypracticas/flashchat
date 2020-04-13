//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        //Código copiado de la pag de Firebase
        //firebase.google.com/docs/auth/ios/password-auth
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    //Navegar a la pantalla de chat
                    self?.performSegue(withIdentifier: "LoginToChat", sender: self)
                }
            }
        }
    }
}


