//
//  RegistroTableViewController.swift
//  catsit
//
//  Created by David Reyes on 6/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class RegistroTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var idUsuario: UITextField!
    
    @IBOutlet weak var nombre: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var contrasena: UITextField!
    
    @IBOutlet weak var confirma: UITextField!
    
    @IBOutlet weak var condiciones: UISwitch!
    
    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBAction func confirmar(sender: UIButton) {
        
        
        //Mostrar indicador de actividad
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.startAnimating()
        
        // variable para registrar si algún campo tiene errores
        var error:Bool = false
        
        // Verificar campo idUsuario
        
        if idUsuario.text == ""{
            
            error=true
            idUsuario.backgroundColor = UIColor.redColor()
        }
        else
        {
            idUsuario.backgroundColor = UIColor.whiteColor()
            
        }
        
        // Verificar campo nombre
        
        if nombre.text == ""{
          
            error=true
            nombre.backgroundColor = UIColor.redColor()
        }
        else
        {
            nombre.backgroundColor = UIColor.whiteColor()
        }
        
        // Verificar campo email
        
        if email.text == ""{
            
            error=true
            email.backgroundColor = UIColor.redColor()
        }
        else
        {
            email.backgroundColor = UIColor.whiteColor()
        }

        // Verificar campo contrasena
        
        if contrasena.text == ""{
            
            error=true
            contrasena.backgroundColor = UIColor.redColor()
        }
        else
        {
            contrasena.backgroundColor = UIColor.whiteColor()
        }

        // Verificar campo confirmación contraseña si ya están informados todos los campos
        
        if contrasena.text != confirma.text && error==false{
            
            error=true
            confirma.backgroundColor = UIColor.redColor()
            contrasena.backgroundColor = UIColor.redColor()
            
            let alertController = UIAlertController(title: "Error", message: "Las contraseñas no coinciden", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else
        {
            if contrasena.text != ""
            {
                // si la contraseña está informada
                confirma.backgroundColor = UIColor.whiteColor()
                contrasena.backgroundColor = UIColor.whiteColor()
        
            }
        }
        //Verificar si se han aceptado las condiciones y no hay otros errores
        if !condiciones.on && error == false
        {
            
            let alertController = UIAlertController(title: "Error", message: "Por favor acepte las condiciones de uso", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            error = true
            
            
        }
        
        
           
        if error==false
            {
                let backendless = Backendless.sharedInstance()
                let user: BackendlessUser = BackendlessUser()
        
                user.email = email.text
                user.password = contrasena.text
                user.setProperty("idusuario", object: idUsuario.text)
                user.setProperty("name", object: nombre.text)
        
                    backendless.userService.registering(user, response:
                            { (registeredUser) -> Void in
                                // correcto
                                let email = registeredUser.email
                                print ("Usuario \(email) registrado correctamente")
                                
                                // Si el usuario se ha registrado correctamente se realiza el login automáticamente
                                backendless.userService.login(self.idUsuario.text, password: self.contrasena.text,
                                    response: { (logedInUser) -> Void in
                                        
                                        // codigo en caso de login correcto
                                        let email = logedInUser.email
                                        print("Hola \(email)")
                                        
                                        
                                        
                                        // Llama al Tab Bar Controller de la pantalla principal
                                        self.performSegueWithIdentifier("RegisterToNavigation", sender: self)
                                        
                                        
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

                                
                                
                               
                                
                            },
                            error: { (error) -> Void in
                                // error
                                let message = error.message
                                print("Error registrando: \(message)")
                                
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
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prepara el indicador de actividad
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.grayColor()
        self.view.addSubview(self.indicador)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
            
        case idUsuario:
            
            nombre.becomeFirstResponder()
            
        case nombre:
            
            email.becomeFirstResponder()
            
        case email:
            
            contrasena.becomeFirstResponder()
            
        case contrasena:
            
            confirma.becomeFirstResponder()
            
            
        default:
            
            textField.resignFirstResponder()
            
        }
        
        return false
        
}
}