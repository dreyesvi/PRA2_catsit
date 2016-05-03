//
//  MiPerfilViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class MiPerfilViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var idUsuario: UITextField!
    
    
    @IBOutlet weak var nombre: UITextField!
    
    
    
    @IBOutlet weak var email: UITextField!
    
    
    @IBAction func cerrarSesionButton(sender: AnyObject) {
        
        
        //Cerrar sesión y volver a la pantalla de login
        Types.tryblock({ () -> Void in
            
            
            let backendless = Backendless.sharedInstance()
            backendless.userService.logout()
            print("User logged out")
            
            
            },
                       
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception as! Fault)")
            }
        )
        
        
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backendless = Backendless.sharedInstance()
        let user = backendless.userService.currentUser
        
        
                   
            email.text = user.email
            nombre.text = user.getProperty("name") as? String
            idUsuario.text = user.getProperty("idusuario") as? String
          
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}