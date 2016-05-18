//
//  DetalleSitioViewController.swift
//  catsit
//
//  Created by David Reyes on 9/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class DetalleSitioViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var descripcionTextView: UITextView!
    
    
    @IBOutlet weak var gestionarFotos: UIButton!
    
    @IBOutlet weak var obtenerUbicacion: UIButton!
    
    // variable para guardar los datos del nuevo sitio
    var sitio: Sitio?
    // variable para guardar los datos de localizacion
    var localizaSitio: GeoPoint?
    // variable para guardar si se  ha podido guardar el sitio correctamente
    var errorAlGuardar: Bool = false
    // mensaje de error
    var mensajeError: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Cuando se pulsa la tecla siguiente se pasa el foco al campo descripción
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
     
        case nombreTextField:
        
            descripcionTextView.becomeFirstResponder()
            
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    // Cuando se pulsa la tecla enter en el campo descripción se esconde el teclado
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    /*
       Se utiliza para pasar parámetros a otros View Controllers
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
      // Pasa parámetros a la pantalla HacerFotoViewController para mostrar
      // el nombre del sitio
     if segue.identifier == "segueFotos" {

         // pasa como parámetro el identificador del nuevo sitio a la pantalla de fotos 
         let vcDestino = segue.destinationViewController as! HacerFotoViewController
        
            let sitio = Sitio()
        
            sitio.nombre = nombreTextField.text
        
            vcDestino.sitio = sitio
            }
            
       
        
    }
    

    /*
       Unwind segue que se llama cuando se pulsa el botón "Save" de la pantalla MapaSitioViewController
       Actualiza la localización del sitio.
     */
    @IBAction func saveLocalizacion(segue:UIStoryboardSegue) {
        
        
        if let MapaSitioViewController = segue.sourceViewController as? MapaSitioViewController {
            
            if let location = MapaSitioViewController.location {
                
                //Actualiza la localización del sitio
                localizaSitio = GeoPoint(point: GEO_POINT(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude), categories: nil)
                print("localización guardada: \(location.coordinate.latitude) \(location.coordinate.longitude)")
                
            }
        }
    }


    
    /*
     Al presionar el botón de añadir fotos se valida que el nombre del sitio esté informado
     porque es el id que se utiliza para guardar las fotos. Sino está informado se muestra 
     un error.
    */
    @IBAction func addFotos(sender: UIButton) {
        
        // Verificar campo nombre
        if nombreTextField.text == ""{

            nombreTextField.backgroundColor = UIColor.redColor()
            
            let alertController = UIAlertController(title: "Error", message: "Introduzca nombre del sitio", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)

            
        }
        else
        {
            nombreTextField.backgroundColor = UIColor.whiteColor()
        }

    }

    
    
    
    
    /*
     Por coherencia con el botón añadir fotos al presionar el botón de añadir ubicación se valida 
     que el nombre del sitio esté informado porque es el id que se utiliza para guardar las fotos.
     Sino está informado se muestra un error. Realmente el nombre del sitio no se utiliza en el 
     mapa por lo que se podría eliminar esta validación
     */
    @IBAction func addUbicacion(sender: UIButton) {
        
        // Verificar campo nombre
        
        if nombreTextField.text == ""{

            nombreTextField.backgroundColor = UIColor.redColor()
            
            let alertController = UIAlertController(title: "Error", message: "Introduzca nombre del sitio", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            nombreTextField.backgroundColor = UIColor.whiteColor()
        }
    }
    

    
    
    /*
      Cuando se pulsa el botón guardar. Guarda los datos del nuevo sitio.
     Las fotos ya se han guardado conforme se han añadido al sitio.
     Se guarda en modo asincrono, si es correcto se hace un segue a la pantalla
     mis sitios para actualizar el table view controller.
    */

    @IBAction func guardarSitio(sender: UIBarButtonItem) {
        
        
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true
        indicador.startAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {

            let backendless = Backendless.sharedInstance()
            
            let user = backendless.userService.currentUser
            
            
            // Obtiene el valor del campo idusuario del usuario actual en un string
            let idUsuario = user.getProperty("idusuario") as! String
            
            //sitio = Sitio(idSitio: idSitio, nombre: nombreTextField.text!, descripcion: descripcionTextView.text, idUsuario: idUsuario)
            self.sitio = Sitio()
            self.sitio?.nombre=self.nombreTextField.text
            self.sitio?.descripcion=self.descripcionTextView.text
            if self.localizaSitio != nil{
                self.sitio?.localizacion=self.localizaSitio
            }
            else{
                self.sitio?.localizacion = GeoPoint()
            }
            
            self.sitio?.usuario_idUsuario=idUsuario
            
            let dataStore = backendless.data.of(Sitio.ofClass());
            Types.tryblock({ () -> Void in
                
                let result = dataStore.save(self.sitio) as? Sitio
                print ("id objecto: \(result!.objectId)")
                print("Sitio guardado con id: \(self.nombreTextField.text!)")
                self.errorAlGuardar = false
                // Actualiza el id del objeto guardado en la base de datos
                self.sitio?.objectId = result!.objectId
                
                // realiza un segue a "saveEditarSitio" pantall MisSitios
                self.performSegueWithIdentifier("saveDetalleSitio", sender: self)
                
                },
                           catchblock: { (exception) -> Void in
                            print("Server reported an error: \(exception)")
                            print("id sitio: \(self.nombreTextField.text!)")
                            print("id usuario: \(idUsuario)")
                            
                            self.errorAlGuardar = true
                            
                             let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                             let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                             alertController.addAction(OKAction)
                             self.presentViewController(alertController, animated: true, completion: nil)
                            
            })
            // Para el indicador de actividad
            indicador.stopAnimating()
        })
        
        
        
        
    }
    
    
    
    
    
    // Pulsa el botón cancel, se cancela el alta del sitio por lo que se borran las fotos
    // del sitio
    @IBAction func cancelSitio(sender: UIBarButtonItem) {
        
        
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true
        indicador.startAnimating()
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let backendless = Backendless.sharedInstance()
            
            let user = backendless.userService.currentUser
            
            var error: Fault?
            
            
            
            // Path donde se guardan las fotos en backendless
            let path = "FotosSitios/"
            
            // Obtiene el valor del campo idusuario del usuario actual en un string
            let idUsuario = user.getProperty("idusuario") as! String
            
            // Prepara una consulta a la tabla imagen filtrando solo las fotos del nuevo sitio del usuario
            let query = BackendlessDataQuery()
            let whereClause = "idUsuario = '\(idUsuario)' and idSitio='\(self.nombreTextField.text!)'"
            query.whereClause = whereClause
            
            let dataStore = backendless.data.of(Imagen.ofClass());
            
            Types.tryblock({ () -> Void in
                
                // realiza la consulta a la bb.dd y obtiene los resultados
                let imagenes = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                let currentPage = imagenes.getCurrentPage()
                
                if currentPage.count==0
                {
                        // realiza un segue a "cancelEditarSitio" pantall MisSitios
                        self.performSegueWithIdentifier("cancelToSitioViewController", sender: self)
                    
                    
                }
                else
                {
                    
                
                
                // recorre las imágenes y borra una a una
                for img in currentPage as! [Imagen] {
                    
                    // Borrado del fichero de imagen
                    
                    var nomfichero = String(img.idImagen) + ".jpg"
                    
                    nomfichero = path + nomfichero
                    
                    let result = backendless.fileService.remove(nomfichero)
                    print("Filchero borrado: \(nomfichero) result= \(result)")
                    
                    // Borrado de la imagen de la bb.dd.
                    let resultbbdd = dataStore.remove(img, fault: &error)
                    if error == nil {
                        print("Imagen borrada bb.dd: \(img.idImagen) codigo: \(resultbbdd)")

                    }
                    else {
                        print("Server reported an error: \(error)")
                        
                        self.errorAlGuardar = true
                    }
                }
                    if self.errorAlGuardar==true
                    {
                        let alertController = UIAlertController(title: "Error", message: "No se han podido borrar fotos temporales", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    else{
                    // realiza un segue a "cancelEditarSitio" pantall MisSitios
                    self.performSegueWithIdentifier("cancelToSitioViewController", sender: self)
                    }
                }
                
                },
                
                catchblock: { (exception) -> Void in
                    print("Server reported an error: \(exception as! Fault)")
                    self.errorAlGuardar = true
                    
                    let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            )
            // para el indicador de actividad
            indicador.stopAnimating()
        })
    }
    
    

}
