//
//  EditarSitioTableViewController.swift
//  catsit
//
//  Created by David Reyes on 14/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class EditarSitioTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate  {

    
    // variables para acceder a los componentes de la vista
    @IBOutlet weak var editarSitio: UIBarButtonItem!
    @IBOutlet weak var deleteSitio: UIBarButtonItem!
    @IBOutlet weak var cancelSitio: UIBarButtonItem!
    @IBOutlet weak var titulo: UINavigationItem!
    @IBOutlet weak var descripcionTextView: UITextView!
    @IBOutlet weak var coleccionFotos: UICollectionView!
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var obtenerLocalizacion: UIButton!
    @IBOutlet weak var addFotos: UIButton!
    @IBOutlet weak var refrescarFotos: UIBarButtonItem!
    @IBOutlet weak var mensajeMapa: UILabel!
    @IBOutlet weak var mensajeFotos: UILabel!
    
    
    
    // variable para guardar los datos del nuevo sitio
    var sitio: Sitio?
    // variable para guardar los datos de localizacion
    var localizaSitio: GeoPoint?
    // indica si se ha pulsado el botón "Edit"
    var isEditingMode = false
    // Array con las fotos de un sitio
    var imagenesArray:[UIImage] = []
    var arrayImagenes:[Imagen]=[]
    // posición de la imagen seleccionada
    var celdaSeleccionada = 0
    
    // variable para guardar si se detecta un error
    var errorDetectado: Bool = false
    
    
    
    /*
    Carga los datos de detalle de un sitio pasados como parámetro y conecta con backendless 
    para consultar la lista de imágenes del sitio seleccionado del usuario activo.
    Carga la lista en las variable “arrayImagenes” para los datos de la imagen y “imagenesArray”
    para las “UIImage”. Si el sitio tiene localización la muestra como anotación en un mapa.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asigna el nombre del sitio (pasado como parámetro) a título de la pantalla
        titulo.title = sitio?.nombre
        // Asigna la descripción del sitio (pasado como parámetro).
        descripcionTextView.text = sitio?.descripcion
        
        // Si el sitio tiene localización muestra la posición en el mapa
        // como una anotación
        if (sitio!.localizacion != nil){
            if (sitio!.localizacion!.longitude != 0 && sitio!.localizacion!.latitude != 0)
            {
                // convierte un GeoPoint a formato CLLocation
                let location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(sitio!.localizacion!.latitude!),
                longitude: CLLocationDegrees(sitio!.localizacion!.longitude!))
                // posiciona la vista del mapa a la región de las coordenadas del sitio
                let span = MKCoordinateSpan(latitudeDelta: 0.005,longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location, span: span)
                mapa.setRegion(region, animated: true)
                // muestra la posición en el mapa con el nombre del sitio
                let nota = MKPointAnnotation()
                nota.coordinate = location
                nota.title = sitio?.nombre
                mapa.addAnnotation(nota)
                mapa.hidden=false
                mensajeMapa.hidden=true
                mapa.showsUserLocation = true
            }
            else
            {
                //sino hay localización oculta el mapa y muestra un texto
                mapa.hidden=true
                mensajeMapa.hidden=false
            }
        }
        else{
            //sino hay localización oculta el mapa y muestra un texto
            mapa.hidden=true
            mensajeMapa.hidden=false
        }
           // leer todas las fotos del sitio
        
        
           let backendless = Backendless.sharedInstance()
           // Prepara una consulta a la tabla sitio filtrando solo el sitio seleccionado del usuario
           let query = BackendlessDataQuery()
           let whereClause = "idUsuario = '\(self.sitio!.usuario_idUsuario!)' and idSitio = '\(self.sitio!.nombre!)'"
           query.whereClause = whereClause
        
                    Types.tryblock({ () -> Void in
                            // realiza la consulta a la bb.dd y obtiene los resultados
                            let sitios = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                            let currentPage = sitios.getCurrentPage()

                        if currentPage.count==0 {
                         
                            //Si no hay imagenes asociadas al sitio se oculta el CollectionView y se muestra
                            // un mensaje
                            self.coleccionFotos.hidden=true
                            self.addFotos.hidden=true
                            self.mensajeFotos.hidden=false
                        }
                        else
                        {
                            self.mensajeFotos.hidden=true
                            self.coleccionFotos.hidden=false
                            self.addFotos.hidden=true
                            
                        
                            // Carga la información de las imágenes en un array
                            for imagen in currentPage as! [Imagen] {
                                     self.arrayImagenes.append(imagen)
                                if let url  = NSURL(string: imagen.imagen!),
                                    data = NSData(contentsOfURL: url)
                                {
                                    self.imagenesArray.append(UIImage(data: data)!)
                                }
                                    }
                        }
                        },
                            catchblock: { (exception) -> Void in
                            print("Server reported an error: \(exception)")
                            print (whereClause)
                            let mensaje = exception.message
                            let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                            alertController.addAction(OKAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                   
                    })
        }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    
    /*
    Devuelve el número de secciones que tiene el table view, en este caso solo 1.
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    
    /*
     Devuelve el número de filas que tiene la tabla, en este caso es 3.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }

    
    
    /*
     La funcionalidad es alterna en función de si el label es “Edit” o “Save”, si es “Edit” oculta 
     el mapa, muestra el botón de “obtener localización”, pone el campo “descripción” en modo editable
     y si no hay fotos muestra el botón “Añadir fotos”. Si es “Save” muestra el mapa,  oculta los botones 
     y deshabilita la edición en el campo descripción.
    */
    @IBAction func editButton(sender: UIBarButtonItem) {
        
     

        
        if isEditingMode
        {
            // Pulsa botón "Done" se muestra el
            // mapa y se oculta el boton
            
            descripcionTextView.editable = false
            editarSitio.title = "Edit"
            isEditingMode = false
            // Sino hay imágenes muestra el botón de añadir fotos
            if arrayImagenes.count==0{
                mensajeFotos.hidden=true
                addFotos.hidden=false
            }
            else
            {
                mensajeFotos.hidden=true
                addFotos.hidden=true
            }
            
            //Mostrar indicador de actividad
            let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
            indicador.center = self.view.center;
            self.view.addSubview(indicador)
            indicador.hidesWhenStopped=true
            indicador.hidden=false
            
            
            
            
            // Actualiza la descripción del sitio
            sitio?.descripcion=descripcionTextView.text
            
            // Actualiza la localización del sitio
            if localizaSitio != nil{
                sitio?.localizacion=localizaSitio
               }
            
            // muestra el mapa si hay localización
            if sitio?.localizacion != nil
            {
                if (sitio!.localizacion!.longitude != 0 && sitio!.localizacion!.latitude != 0)
                {
                    obtenerLocalizacion.hidden = true
                    mensajeMapa.hidden=true
                    mapa.hidden = false
                }
                else
                {
                    mapa.hidden = true
                    mensajeMapa.hidden = false
                    obtenerLocalizacion.hidden = true
                }
            }
            else
            {
                mapa.hidden = true
                mensajeMapa.hidden = false
                obtenerLocalizacion.hidden = true
            }
            indicador.startAnimating()
            dispatch_async(dispatch_get_main_queue(), {
                
                // conecta con la instancia actual
                let backendless = Backendless.sharedInstance()
                    
                // Actualiza el sitio en la bb.dd.
                let dataStore = backendless.data.of(Sitio.ofClass());
                Types.tryblock({ () -> Void in
                    
                    let result = dataStore.save(self.sitio) as? Sitio
                    print ("id objecto: \(result!.objectId)")
                    print("Sitio actualiado  id: \(self.sitio?.nombre)")
                    },
                               catchblock: { (exception) -> Void in
                                print("Server reported an error: \(exception)")
                                print("id sitio: \(self.sitio?.nombre)")
                                print("id usuario: \(self.sitio?.usuario_idUsuario)")
                                let mensaje = exception.message
                                let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                                alertController.addAction(OKAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                    })
      
                    // Se ha actualizar el collectionView para refrescar fotos
                       self.refrescarFotos(UIBarButtonItem())
                    
                    // Parar animacion y volver a permitir interacción
                    indicador.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
            
            
        }
        else
        {
            // Pulsa el botón "Edit"
            // Oculta el mapa y muestra el botón para llamar a la pantalla de localización
            
            obtenerLocalizacion.hidden = false
            mapa.hidden = true
            mensajeFotos.hidden = true
            mensajeMapa.hidden = true
            descripcionTextView.editable = true
            editarSitio.title = "Done"
            isEditingMode = true
            
            // Sino hay imágenes muestra el botón de añadir fotos
            if arrayImagenes.count==0{
                mensajeFotos.hidden=true
                addFotos.hidden=false
            }
            else
            {
                mensajeFotos.hidden=true
                addFotos.hidden=true
            }
        }
    }
    

    
    
    
    /*
    Es un unwind segue que se llama cuando en la pantalla “MapaSitioViewController” 
     se pulsa el botón “save”. Obtiene el parámetro “location” con la ubicación obtenida en 
     la pantalla y actualiza la variable “localizaSitio” que posteriormente cuando se pulse el 
     botón “save” en la pantalla actual se guardará en la base de datos.
     */
    @IBAction func saveLocalizacion(segue:UIStoryboardSegue) {
        
        if let MapaSitioViewController = segue.sourceViewController as? MapaSitioViewController {
            
            if let location = MapaSitioViewController.location {
                
                //Actualiza la localización del sitio
                localizaSitio = GeoPoint(point: GEO_POINT(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude), categories: nil)
                print("localización guardada: \(location.coordinate.latitude) \(location.coordinate.longitude)")
                
                // borra el sitio marcado en el mapa
                let allAnnotations = self.mapa.annotations
                self.mapa.removeAnnotations(allAnnotations)
                // convierte un GeoPoint a formato CLLocation
                let location = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(localizaSitio!.latitude),
                    longitude: CLLocationDegrees(localizaSitio!.longitude))
                // posiciona la vista del mapa a la región de las coordenadas actualizadas del sitio
                let span = MKCoordinateSpan(latitudeDelta: 0.005,longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location, span: span)
                mapa.setRegion(region, animated: true)
                // muestra la posición actualizada en el mapa con el nombre del sitio
                let nota = MKPointAnnotation()
                nota.coordinate = location
                nota.title = sitio?.nombre
                mapa.addAnnotation(nota)
                mapa.showsUserLocation = true
                

                
            }
        }
        
    }

    

    
    
    
    
    
    /*
     Si se pulsa el botón borrar (imagen de una papelera) se muestra un mensaje de confirmación al usuario. 
     Si el usuario confirma el borrado se realiza un unwind manual a “deleteEditarSitio” de la pantalla 
     “MisSitiosTableViewController”. Si el usuario no confirma la acción se mantiene en la pantalla de detalle del sitio.
     
     -	Consulta todas las imágenes de un sitio de un usuario.
     -	Borra cada fichero de imagen y cada fila de la bb.dd de la imagen.
     -	Borra el sitio de la bb.dd.
 
    */
    @IBAction func borrarButton(sender: UIBarButtonItem) {
        
        // Muestra un mensaje de confirmación
        let refreshAlert = UIAlertController(title: "Delete", message: "Se borrarán todos los datos del Sitio", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
            
            var mensaje: String = " "
            
            //Mostrar indicador de actividad
            let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            indicador.center = self.view.center;
            self.view.addSubview(indicador)
            self.view.bringSubviewToFront(indicador)
            indicador.hidden=false
            indicador.hidesWhenStopped=true
            indicador.startAnimating()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Conecta con la instancia actual de backendless
                let backendless = Backendless.sharedInstance()
                
                //Usuario actual de la instancia de backendless
                let user = backendless.userService.currentUser
                
                // variable para capturar el código de error.
                var error: Fault?
                
                // Path donde se guardan las fotos en backendless
                let path = "FotosSitios/"
                
                // Obtiene el valor del campo idusuario del usuario actual en un string
                let idUsuario = user.getProperty("idusuario") as! String
                
                // Prepara una consulta a la tabla imagen filtrando solo las fotos del sitio del usuario
                let query = BackendlessDataQuery()
                let whereClause = "idUsuario = '\(idUsuario)' and idSitio='\(self.sitio!.nombre!)'"
                query.whereClause = whereClause
                
                // Asocia la tabla de backendless a la clase Imagen
                let dataStore = backendless.data.of(Imagen.ofClass());
                
                Types.tryblock({ () -> Void in
                    
                    // realiza la consulta a la bb.dd y obtiene los resultados
                    let imagenes = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                    let currentPage = imagenes.getCurrentPage()
                    
                    // recorre las imágenes y borra una a una
                    for img in currentPage as! [Imagen] {
                        
                        // Borrado del fichero de imagen (idImagen + extensión jpg)
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
                            self.errorDetectado = true
                            mensaje = error!.message
                        }
                    }
                    },
                    catchblock: { (exception) -> Void in
                        // muestra el mensaje de error en caso de problemas
                        print("Server reported an error: \(exception as! Fault)")
                        self.errorDetectado = true
                        mensaje = exception.message
                        
                        

                    }
                )
                
                
                // Asocia la tabla de backendless a la clase Sitio
                let dataStoreSitio = backendless.data.of(Sitio.ofClass());
                Types.tryblock({ () -> Void in
                    
                    // Borra el sitio
                    let resultbbddsitio = dataStoreSitio.remove(self.sitio, fault: &error)
                    if error == nil {
                        print("Sitio borrado de la bb.dd: \(self.sitio!.nombre) codigo: \(resultbbddsitio)")
                    }
                    else {
                        print("Server reported an error: \(error)")
                        self.errorDetectado = true
                        mensaje = error!.message
                    }
                    
                    },
                    catchblock: { (exception) -> Void in
                        // Muestra un mensaje de error en caso de problemas
                        print("Server reported an error: \(exception as! Fault)")
                        self.errorDetectado = true
                        mensaje = exception.message
                    }
                )
                
                // Parar animacion
                indicador.stopAnimating()
               
                
                if self.errorDetectado
                {
                    let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
               else
                {
                    // realiza un segue a "deleteEditarSitio" pantalla MisSitios
                    self.performSegueWithIdentifier("deleteEditarSitio", sender: self)
                }
                
           })


            }))
        
        refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .Cancel, handler: { (action: UIAlertAction!) in
            }))
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
   
    
    
    
    
    
    
    
   /*
     Devuelve el número de imágenes del sitio.
   */
   func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
        return imagenesArray.count
    }
    
    
    
    
    
    /*
    Carga las imágenes del sitio en la celda prototipo. Lee las imágenes del array de “UIImage”.
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true
        indicador.startAnimating()
        
      
            
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CellFotoCollectionViewCell
        dispatch_async(dispatch_get_main_queue(), {
            
            cell.foto.image = self.imagenesArray[indexPath.row]
            // Para el indicador de actividad
            indicador.stopAnimating()
        })
        
        return cell
    }

    
    
    
    
    /*
     Asigna a la variable celdaSeleccionada el índice de la imagen seleccionada. 
     Posteriormente se utiliza para mostrarla en la pantalla de “FotoViewController”.
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        celdaSeleccionada = indexPath.row
    }

    
    
    /*
     Pasa parámetros a otros view controllers. Se utiliza cuando se pulsa la primera fila, en la colección de imágenes.
     -	“verDetalleFoto”: Pasa el parámetro imagen, si no hay imágenes le pasa solo el id del sitio para añadir nuevas fotos.
    */
    // Pasa parámetros a otros View Controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verDetalleFoto" {
 
            // pasa como parámetro los datos de la imagen seleccionada
            let nav = segue.destinationViewController as! FotoViewController
            
            if (!self.arrayImagenes.isEmpty) {
                nav.imagen = Imagen()
                nav.imagen = self.arrayImagenes[celdaSeleccionada]
            }
            else{
                // no tiene imágenes pero se le pasa el id del sitio para añadir fotos
                nav.imagen = Imagen()
                nav.imagen?.idSitio = self.sitio?.nombre
            }
         }
     }

    
    
    
    /*
    Unwind segue que se ejecuta cuando en la pantalla “FotoViewController” se pulsa el botón “borrar”.  
     Elimina el elemento de los arrays y actualiza el collection view.
    */
    @IBAction func borrarFotoSegue(segue:UIStoryboardSegue) {
        
        // Se ha borrado una imagen se actualiza el collectionView
        self.refrescarFotos(UIBarButtonItem())
        celdaSeleccionada=0
        if imagenesArray.count==0 {
            coleccionFotos.hidden=true
            mensajeFotos.hidden=false
        }
        else{
            coleccionFotos.hidden=false
            mensajeFotos.hidden=true
        }
    }
    
    
    

    /*
    Cuando se pulsa el botón “refresco” se borran todas las imágenes actuales
     de los arrays y se vuelven a leer todas las imágenes del sitio.
    */
    @IBAction func refrescarFotos(sender: UIBarButtonItem) {
        
        // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        
        //indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = self.view.center;
        indicador.hidesWhenStopped=true
        
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        
        
        // Borra las fotos del array de fotos
        self.arrayImagenes.removeAll()
        self.imagenesArray.removeAll()
        
        indicador.startAnimating()
        dispatch_async(dispatch_get_main_queue(), {
        
      
            // leer todas las fotos del sitio
            let backendless = Backendless.sharedInstance()
            
            // Prepara una consulta a la tabla sitio filtrando solo las imágenes del sitio del usuario
            let query = BackendlessDataQuery()
            let whereClause = "idUsuario = '\(self.sitio!.usuario_idUsuario!)' and idSitio = '\(self.sitio!.nombre!)'"
            query.whereClause = whereClause
            
            Types.tryblock({ () -> Void in
                
                // realiza la consulta a la bb.dd y obtiene los resultados
                let sitios = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                let currentPage = sitios.getCurrentPage()
                
                if currentPage.count==0 {
                    
                    //Si no hay imagenes asociadas al sitio se oculta el CollectionView y se muestra
                    // un mensaje
                    self.coleccionFotos.hidden=true
                    self.addFotos.hidden=true
                    self.mensajeFotos.hidden=false
                }
                else
                {
                    self.coleccionFotos.hidden=false
                    self.addFotos.hidden=true
                    self.mensajeFotos.hidden=true
                    
                    // Carga la información de las imágenes en un array
                    for imagen in currentPage as! [Imagen] {
                        self.arrayImagenes.append(imagen)
                        if let url  = NSURL(string: imagen.imagen!),
                            data = NSData(contentsOfURL: url)
                        {
                            self.imagenesArray.append(UIImage(data: data)!)
                        }
                    }
                }
                },
                           catchblock: { (exception) -> Void in
                            print("Server reported an error: \(exception)")
                            print (whereClause)
                            let mensaje = exception.message
                            let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                            alertController.addAction(OKAction)
                            self.presentViewController(alertController, animated: true, completion: nil)

                })
          
                
            // carga las imágenes en el collection view
            self.coleccionFotos.reloadData()
            indicador.stopAnimating()
            
        })
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

}
