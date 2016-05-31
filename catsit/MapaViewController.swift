//
//  MapaViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class MapaViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var listadoMapaButton: UIBarButtonItem!
    
    @IBOutlet weak var vistaListadoTableViewController: UIView!
    
    @IBOutlet weak var vistaMapaViewController: UIView!
    
    @IBOutlet weak var filtroRadioKm: UISlider!
   
    
    @IBOutlet weak var numKmLabel: UITextField!
    
    // Variable que almacena todos los sitios.
    var sitiosArray:[Sitio] = []

    
    
    
    
    @IBAction func filtroradioKm(sender: AnyObject) {
        
        numKmLabel.text = String(Int(round(filtroRadioKm.value)))
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numKmLabel.text = "1"
        
        
        // Conecta con la instancia de backendless que se ha logineado el usuario
        let backendless = Backendless.sharedInstance()
        
       
        // Prepara una consulta a la tabla sitio para leer todos los sitios
        let query = BackendlessDataQuery()
  
        // indica que obtenga los datos relacionados de localización (GeoPoint)
        let queryOptions = QueryOptions()
        queryOptions.addRelated("localizacion")
        query.queryOptions = queryOptions
        
        Types.tryblock(
            { () -> Void in
                
                // realiza la consulta a la bb.dd y obtiene la lista de sitios del usuario
                let sitios = backendless.persistenceService.of(Sitio.ofClass()).find(query)
                let currentPage = sitios.getCurrentPage()
                
                // Recorre la lista de sitios y carga la información de los sitios en un array
                for sitio in currentPage as! [Sitio]
                {
                    self.sitiosArray.append(sitio)
                }
                
                
                
            }, catchblock: { (exception) -> Void in
                // muestra el mensaje de error
                print("Server reported an error: \(exception)")
          
                
                let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        })

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapListadoMapaButton(sender: UIBarButtonItem) {
        
        if listadoMapaButton.title=="Listado" {
            
            listadoMapaButton.title="Mapa"
            UIView.animateWithDuration(0.5, animations: {
            self.vistaMapaViewController.alpha=0
            self.vistaListadoTableViewController.alpha=1
            })
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
            self.vistaListadoTableViewController.alpha=0
            self.vistaMapaViewController.alpha=1
                })
            listadoMapaButton.title="Listado"
        }
        
            
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        Types.tryblock(
            { () -> Void in

            let numerico = Int(textField.text!)

                if (numerico < 0 || numerico > 10)
                {
                    let alertController = UIAlertController(title: "Error", message: "Solo se permiten valores entre 0 y 10", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else{
                    self.filtroRadioKm.value = Float(numerico!)
                }
                
            }, catchblock: { (exception) -> Void in
                
                let alertController = UIAlertController(title: "Error", message: "Solo se permiten valores numéricos entre 0 y 10", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
        })
            
            textField.resignFirstResponder()
               
        return false
        
    }

    
    
}