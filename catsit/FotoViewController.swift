//
//  FotoViewController.swift
//  catsit
//
//  Created by David Reyes on 15/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class FotoViewController: UIViewController {

    
    @IBOutlet weak var foto: UIImageView!
    @IBOutlet weak var borrarFoto: UIBarButtonItem!
    @IBOutlet weak var addFoto: UIBarButtonItem!

    // variable para pasar la imagen por parámetro
    var imagen: Imagen?
    
    
    
    /*
    Si por parámetro se le ha pasado la dirección web de la imagen se recupera de backendless y se carga en el UIImage.
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        if imagen?.imagen != nil {
            // si se ha pasado una imagen por parámetro se recupera de backendless
            if let url  = NSURL(string: imagen!.imagen!),
                data = NSData(contentsOfURL: url)
            {
                self.foto.image = UIImage(data: data)!
            }
        }
    }

 
    
    
    /*
    Al pulsar el botón borrar se solicita confirmación al usuario, en el caso de que reponda “OK” se borra el fichero de la 
     imagen asociado en backendless, los datos de la imagen de la base de datos 
     y se hace un unwind segue manual a “borrarFotoSegue” a la pantalla de EditarSitioTableViewController.
     */
    @IBAction func borrarFoto(sender: UIBarButtonItem) {
    
        let refreshAlert = UIAlertController(title: "Delete", message: "¿ Desea borrar la imagen?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
            //borrar imagen
            let backendless = Backendless.sharedInstance()
            
            let dataStore = backendless.data.of(Imagen.ofClass());
            
            var error: Fault?
            
            // Borrado del fichero de imagen
            
            var nomfichero = String(self.imagen!.idImagen) + ".jpg"
            
            // Path donde se guardan las fotos en backendless
            let path = "FotosSitios/"
            
            nomfichero = path + nomfichero
            
            Types.tryblock({ () -> Void in
            
                let result = backendless.fileService.remove(nomfichero)
                print("Filchero borrado: \(nomfichero) result= \(result)")
            
                // Borrado de la imagen de la bb.dd.
                let resultbbdd = dataStore.remove(self.imagen, fault: &error)
                if error == nil {
                    print("Imagen borrada bb.dd: \(self.imagen!.idImagen) codigo: \(resultbbdd)")
                }
                else {
                    print("Server reported an error: \(error)")
                    let mensaje = error?.message
                    let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)

                }
                },
                
                catchblock: { (exception) -> Void in
                    print("Server reported an error: \(exception as! Fault)")
                    let mensaje = exception.message
                    let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)

                }
            )
            
            // volver al detalle del sitio.
            self.performSegueWithIdentifier("borrarFotoSegue", sender: self)
        
          }))
    
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .Cancel, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    
    }
    
    
    
  
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
 
    /*
    Cuando se pulsa el botón añadir foto se asigna como delegado esta pantalla (utiliza un protocolo delegado) 
     para recibir la foto tomada. Como parámetro cuando vuelva.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "addFotos" {
            
            // pasa como parámetro el identificador del nuevo sitio a la pantalla de fotos
            let vcDestino = segue.destinationViewController as! HacerFotoViewController
            
            let sitio = Sitio()
            
            sitio.nombre = imagen?.idSitio
            
            vcDestino.sitio = sitio
            
            vcDestino.delegate = self
        }
        
    }
}

// Actualiza la imagen con la imagen capturada en el
// ViewController HacerFotoViewController

extension FotoViewController: VCdevolverFotoDelegate {
    func actualizarFoto (data: UIImage) {
        
        self.foto.image = data
        
    }
}
