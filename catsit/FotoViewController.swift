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
    
    var imagen: Imagen?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      //  foto=imagen
        if imagen?.imagen != nil {
          
        
            if let url  = NSURL(string: imagen!.imagen!),
                data = NSData(contentsOfURL: url)
            {
                self.foto.image = UIImage(data: data)!
            }
        }
        
        
        
        
        
        
        
    }

  
    
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
                }
                },
                
                catchblock: { (exception) -> Void in
                    print("Server reported an error: \(exception as! Fault)")
                }
            )

            

            
            // volver al detalle del sitio.
            self.performSegueWithIdentifier("borrarFotoSegue", sender: self)
        
          }))
    
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .Cancel, handler: { (action: UIAlertAction!) in
            
            
            
            
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)

    
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "addFotos" {
            
            // pasa como parámetro el identificador del nuevo sitio a la pantalla de fotos
            let vcDestino = segue.destinationViewController as! HacerFotoViewController
            
            let sitio = Sitio()
            
            sitio.nombre = imagen?.idSitio
            
            vcDestino.sitio = sitio
        }
        
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
