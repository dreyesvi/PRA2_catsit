//
//  HacerFotoViewController.swift
//  catsit
//
//  Created by David Reyes on 11/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit


/*
 Esta clase tiene definido un protocolo para devolver la imagen realizada 
 o seleccionada a la pantalla “FotoViewController”.
*/
protocol VCdevolverFotoDelegate {
    
    func actualizarFoto(data: UIImage, imagen: Imagen)
    
}

class HacerFotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // variables delegado para controlar los controles UI
    @IBOutlet var imagenFoto: UIImageView!
    @IBOutlet weak var saveFoto: UIBarButtonItem!
   
    // Gestiona la cámara y la selección de imágenes de la galería
    var imagePicker: UIImagePickerController!
    
    // variables de clase
    var sitio: Sitio?
    var imagen: Imagen?
    
    // se utiliza para el protocolo/delegado y devolver la imagen al VC de origen
    // lanza la función actualizarFoto()
    var delegate: VCdevolverFotoDelegate?
    
    
    
    /* Al pulsar el botón Hacer Foto se abre la cámara.
       Se verifica que la cámara esté disponible sino se muestra
       un error.
    */
    @IBAction func hacerFoto(sender: AnyObject) {
        
        // verifica si el dispositivo tiene cámara
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
                // Abre la cámara
                imagePicker =  UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
        
                presentViewController(imagePicker, animated: true, completion: nil)
            }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "Cámara no disponible en el dispositivo", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    

    
    /* Al pulsar el botón Seleccionar Foto se abre la librería de fotos.
     Se verifica que la librería de imágenes esté disponible sino se muestra
     un error.
     */
    @IBAction func seleccionarFoto(sender: AnyObject) {
        
        // Verifica si el dispositivo puede abrir la librería de imágenes
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // Abre la librería de imágenes y muestra las fotos
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "Librería de fotos no disponible", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    

    
    
    
    /*
     Si el usuario selecciona una foto se recupera. Activa el botón guardar.
    */
    func imagePickerController(picker: UIImagePickerController,   didFinishPickingMediaWithInfo info: [String : AnyObject]) {
 
        // recupera la foto cuando el usuario la selecciona
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
    
    
    /*
      Si se pulsa el botón guardar se actualiza la imagen del view control de origen utlizando la extensión.
     Se guarda la foto y el fichero en backendless en modo asíncrono, se muestra un error
     al usuario para confirmar el guardado o un error.
    */
    @IBAction func saveFoto(sender: UIBarButtonItem) {
        
        


        
        // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        //Mostrar indicador de actividad
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        indicador.startAnimating()
       
        // se ejecuta el guardado en asíncrono.
        dispatch_async(dispatch_get_main_queue(), {
        
            let backendless = Backendless.sharedInstance()
        
            let user = backendless.userService.currentUser
        
            // Obtiene el valor del campo idusuario del usuario actual en un string
            let idUsuario = user.getProperty("idusuario") as! String
        
            self.imagen = Imagen()
            self.imagen?.idUsuario = idUsuario
            self.imagen?.idSitio = self.sitio?.nombre
        
            // nombre del fichero de la foto e id de la imagen
            let idImagen = Int(arc4random_uniform(9999999))
        
        
            self.imagen?.idImagen = Int(idImagen)
        
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
            
                // actualiza el id del objeto.
                self.imagen?.objectId = result?.objectId
                
                // desactovar el botón save una vez guardado
                self.saveFoto.enabled = false
                
                // se actualiza la imagen para devolverla al VC de Origen
                self.delegate?.actualizarFoto(self.imagenFoto.image!, imagen: self.imagen!)
           
                // mensaje de confirmacion de que se ha guardado correctamente
                let alertController = UIAlertController(title: "Guardar Foto", message: "Foto Guardada Correctamente", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
       
            
                },
                       
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception as! Fault)")
                        
                        // muestra un mensaje en caso de error
                        let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
            })
            // para el indicador de actividad
            indicador.stopAnimating()
       })
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
