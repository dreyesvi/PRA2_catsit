//
//  ViewController.swift
//  catsit
//
//  Created by David Reyes on 31/3/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // Campo de texto para el id de usuario.
    @IBOutlet weak var idUsuario: UITextField!
    
    // Campo de texto para la contraseña
    @IBOutlet weak var contrasena: UITextField!
    
    // Variable para mostrar el indicador de actividad mientras se está validando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    // Función al hacer click sobre el botón de login.
    @IBAction func login(sender: UIButton) {
    
        
        //Mostrar indicador de actividad
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.startAnimating()

        
        
        // Validación de que en los campos de texto esten informados
        var error:Bool=false
        
        if idUsuario.text==""{
            
            error = true
            idUsuario.backgroundColor = UIColor.redColor()
            
        }
        else
        {
            idUsuario.backgroundColor = UIColor.whiteColor()
            
        }
        
        if contrasena.text=="" {
            
            error = true
            contrasena.backgroundColor = UIColor.redColor()
            
        }
        else
        {
            contrasena.backgroundColor = UIColor.whiteColor()
            
        }
        
        
        if error==true
        {
          // Si se ha detectado un error se muestra un mensaje al usuario
            
            let alertController = UIAlertController(title: "Error", message: "Por favor complete los campos en rojo", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else{
          // Sino se ha detectado un error se valida el usuario y contrasena
        
            
                let backendless = Backendless.sharedInstance()
        
                backendless.userService.login(idUsuario.text, password: contrasena.text,
                                      response: { (logedInUser) -> Void in
                                        
                                        // codigo en caso de login correcto
                                        let email = logedInUser.email
                                        print("Hola \(email)")
                                        
                                        // Llama al Tab Bar Controller de la pantalla principal
                                        self.performSegueWithIdentifier("LoginToNavigation", sender: self)
                                        
                                        
                    },
                                      error: { (error) -> Void in
                                        // código en caso de login erroneo
                                        let message = error.message
                                        print("Error en login: \(message)")
                                        
                                        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                                        let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                                        alertController.addAction(OKAction)
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        
                    })

            }
       
        // Parar animacion y volver a permitir interacción
       UIApplication.sharedApplication().endIgnoringInteractionEvents()
       indicador.stopAnimating()
    
    }
    
    @IBAction func returnActionForSegue(segue: UIStoryboardSegue){
        
        // Cuando cierra sesión el usuario se vacian los campos de texto.
        idUsuario.text=""
        contrasena.text=""
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // prepara el indicador de actividad 
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .Gray
        self.indicador.color = UIColor.grayColor()
        self.view.addSubview(self.indicador)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            
        case idUsuario:
            
            contrasena.becomeFirstResponder()
            
        default:
            
            textField.resignFirstResponder()
            
        }

        return true
    }

}

