//
//  InformacionViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class InformacionViewController: UIViewController {
    
   
    
    @IBOutlet weak var usuariosRegistrados: UITextField!
    
    @IBOutlet weak var totalSitios: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true

        // activa el símbolo de trabajando...
        indicador.startAnimating()
        
        // ejecuta en modo asincrono la consulta de sitios y usuarios
        dispatch_async(dispatch_get_main_queue(), {

        // Conecta con la instancia de backendless que se ha logineado el usuario
        let backendless = Backendless.sharedInstance()
        
        
        // Prepara una consulta a la tabla sitio y usuario.
        let query = BackendlessDataQuery()
        
        
       
        Types.tryblock(
            { () -> Void in
                
                // realiza la consulta a la bb.dd y obtiene la lista total de sitios
                let sitios = backendless.persistenceService.of(Sitio.ofClass()).find(query)
                self.totalSitios.text = String(sitios.totalObjects)
                

                // realiza la consulta a la bb.dd y obtiene la lista de usuarios registrados
                let usuarios = backendless.persistenceService.of(BackendlessUser.ofClass()).find(query)
                self.usuariosRegistrados.text = String(usuarios.totalObjects)

            }, catchblock: { (exception) -> Void in
                // muestra el mensaje de error
                print("Server reported an error: \(exception)")
                
                let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        })

            
            indicador.stopAnimating()
        })

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
