//
//  HacerFotoViewController.swift
//  catsit
//
//  Created by David Reyes on 11/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class HacerFotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet var imagenFoto: UIImageView!
    @IBOutlet weak var saveFoto: UIBarButtonItem!
   
    
    var imagePicker: UIImagePickerController!
    
    var sitio: Sitio?
    var imagen: Imagen?
    
    
    
    
    @IBAction func hacerFoto(sender: AnyObject) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    

    
    @IBAction func seleccionarFoto(sender: AnyObject) {
        
        
        //let fotoPicker = UIImagePickerController()
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    func imagePickerController(picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imagenFoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Si se recupera una imagen se activa el botón de guardar foto.
        if (imagenFoto.image==nil) {
            self.saveFoto.enabled=false
            }
        else {
            self.saveFoto.enabled=true
        }
        
    }
    
    
    
    
    @IBAction func saveFoto(sender: UIBarButtonItem) {
        
        
        // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        //Mostrar indicador de actividad
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        //indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = self.view.center;
        
        self.view.addSubview(indicador)
        indicador.startAnimating()
        print(indicador)

        
        
        let backendless = Backendless.sharedInstance()
        
        let user = backendless.userService.currentUser
        
        // Obtiene el valor del campo idusuario del usuario actual en un string
        let idUsuario = user.getProperty("idusuario") as! String
        
        imagen = Imagen()
        imagen?.idUsuario = idUsuario
        imagen?.idSitio = sitio?.nombre
        
        // nombre del fichero de la foto e id de la imagen
        //let idImagen = Int(rand())
        let idImagen = Int(arc4random_uniform(9999999))
        
        
        imagen?.idImagen = Int(idImagen)
        
        let dataStore = backendless.data.of(Imagen.ofClass());

        
        Types.tryblock({ () -> Void in
            
            // convierte la foto a formato content NSData
            let data = UIImageJPEGRepresentation(self.imagenFoto.image!, 0.8)
            
            // Path donde se guardan las fotos en backendless
            let path = "FotosSitios/"
            
            // le añade la extensión al nombre de la foto
            let filename = String(idImagen) + ".jpg"
            // path completo de la foto
            let pathfile = path + filename
            // sube la foto a backendless
            let uploadedFile = backendless.fileService.upload(pathfile, content: data, overwrite:true)
            print("File has been uploaded. File URL is - \(uploadedFile.fileURL)")
            
            // guarda el path donde se ha subido la imagen
            self.imagen?.imagen = uploadedFile.fileURL
            
            // guarda los datos de la imagen
            let result = dataStore.save(self.imagen) as? Imagen
            print ("id objecto: \(result!.objectId)")
            
            // desactovar el botón save una vez guardado
            self.saveFoto.enabled = false
           
            
       
            
            },
                       
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception as! Fault)")
        })
        
        
        // Parar animacion y volver a permitir interacción
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
        
        
    }
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        
        
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
