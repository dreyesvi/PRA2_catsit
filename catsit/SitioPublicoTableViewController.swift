//
//  SitioPublicoTableViewController.swift
//  catsit
//
//  Created by David Reyes on 14/6/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class SitioPublicoTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

   // variables para acceder a los componentes de la vista
    @IBOutlet weak var coleccionFotos: FotosCollectionView!
    @IBOutlet weak var cancelSitio: UIBarButtonItem!
    @IBOutlet weak var titulo: UINavigationItem!
    @IBOutlet weak var descripcionTextView: UITextView!
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var mensajeMapa: UILabel!
    @IBOutlet weak var mensajeFotos: UILabel!
    @IBOutlet weak var valoracionUser: UITextField!
    @IBOutlet weak var valoracionMedia: UILabel!
    @IBOutlet weak var guardarValoracion: UIButton!
    
    
    
    // variable para guardar los datos del nuevo sitio
    var sitio: Sitio?
    // variable para guardar los datos de localizacion
    var localizaSitio: GeoPoint?
    // Array con las fotos de un sitio
    var imagenesArray:[UIImage] = []
    var arrayImagenes:[Imagen]=[]
    // posición de la imagen seleccionada
    var celdaSeleccionada = 0
    
    // variable para guardar si se detecta un error
    var errorDetectado: Bool = false
    
    // Variables para gestionar la valoración del usuario
    var valoracionUsuario = 0
    var valoracion: Valoracion?
    
    
    
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
        if sitio?.valoracionMedia != 0
        {
            valoracionMedia.text = String(sitio!.valoracionMedia)
        }
        else {
            valoracionMedia.text = "n/a"
        }
        
        
        let backendless = Backendless.sharedInstance()
        let user = backendless.userService.currentUser
        // Obtiene el valor del campo idusuario del usuario actual en un string
        let idUsuario = user.getProperty("idusuario") as! String
        
        // verifica si el sitio es propiedad del usuario
        if sitio?.usuario_idUsuario == idUsuario
        {
            // Un usuario no puede valorar sus propios sitios.
            self.valoracionUser.enabled = false
            self.guardarValoracion.enabled = false
            self.valoracionUser.text = "n/a"
            
        }
        else
        {
            self.valoracionUser.enabled = true
            self.guardarValoracion.enabled = true
        // Leer la valoración del usuario (si ya la ha realizado)
        
        // Prepara una consulta a la tabla sitio filtrando solo el sitio seleccionado del usuario
        let query = BackendlessDataQuery()
        query.whereClause = "sitio_idSitio = '\(self.sitio!.objectId!)' and users_idUsuario = '\(user.objectId!)'"
        
        Types.tryblock({ () -> Void in
            
        
        // realiza la consulta a la bb.dd y obtiene los resultados
        let valoraciones = backendless.persistenceService.of(Valoracion.ofClass()).find(query)
        
            let currentPage = valoraciones.getCurrentPage()
            if currentPage.count==0 {
                
                // el usuario no ha realizado una valoracion todavía
                self.valoracionUser.text = ""
            }
            else
            {
                for valoracion in currentPage as! [Valoracion] {
                    
                    self.valoracionUser.text = String(valoracion.valoracion)
                    self.valoracionUsuario = valoracion.valoracion
                    self.valoracion = valoracion
                    
                }
                
            }
        
            },
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception)")
                        print (query.whereClause)
                        let mensaje = exception.message
                        let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
        })

       }
        
        
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
        
        //backendless = Backendless.sharedInstance()
        // Prepara una consulta a la tabla sitio filtrando solo el sitio seleccionado del usuario
        var queryImagen = BackendlessDataQuery()
        queryImagen = BackendlessDataQuery()
        queryImagen.whereClause = "idUsuario = '\(self.sitio!.usuario_idUsuario!)' and idSitio = '\(self.sitio!.nombre!)'"
        
        Types.tryblock({ () -> Void in
            // realiza la consulta a la bb.dd y obtiene los resultados
            let sitios = backendless.persistenceService.of(Imagen.ofClass()).find(queryImagen)
            let currentPage = sitios.getCurrentPage()
            
            if currentPage.count==0 {
                
                //Si no hay imagenes asociadas al sitio se oculta el CollectionView y se muestra
                // un mensaje
                self.coleccionFotos.hidden=true
                self.mensajeFotos.hidden=false
            }
            else
            {
                self.mensajeFotos.hidden=true
                self.coleccionFotos.hidden=false
                
                
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
                        print (queryImagen.whereClause)
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
     Posteriormente se utiliza para mostrarla en la pantalla de “FotoPublicaViewController”.
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        celdaSeleccionada = indexPath.row
    }
    
    
    /*
     Pasa parámetros a otros view controllers. Se utiliza cuando se pulsa la primera fila, en la colección de imágenes.
     -	“verFotoPublicaSegue”: Pasa el parámetro imagen.
     */
    // Pasa parámetros a otros View Controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verFotoPublicaSegue" {
            
            // pasa como parámetro los datos de la imagen seleccionada
            let nav = segue.destinationViewController as! FotoPublicaViewController
            
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
     Al pulsar el botón de guardar valoración se valida que el usuario haya entrado un valor válido (1,2,3,4,5)
     Lo primero que se hace es volver a leer la valoración media del sitio (para minimizar problemas de concurrencia)
     Si el usuario ya había realizado una valoración del sitio recalcula la media en función de la antigua y nueva valoración y
     actualiza la valoración en la base de datos.
     Si el usuario no ha realizado una valoración a este sitio calcula la media.
     Guarda la valoración en la base de datos.
    
    */
    
    @IBAction func guardarValoracion(sender: UIButton) {
        
        if (valoracionUser.text=="1") || (valoracionUser.text=="2") || (valoracionUser.text=="3") || (valoracionUser.text=="4")
            || (valoracionUser.text=="5")
            
        {
            valoracionUser.backgroundColor = UIColor.whiteColor()
            
            //Leer la valoracion media actual
            var nuevaValoracionMedia: Double = 0
            var valoracionMediaSitio: Double = 0

            // Leer la valoración del usuario (si ya la ha realizado)
            let backendless = Backendless.sharedInstance()
            // Prepara una consulta a la tabla sitio filtrando solo el sitio seleccionado del usuario
            let query = BackendlessDataQuery()
            query.whereClause = "objectId = '\(self.sitio!.objectId!)' "
            
            
                // realiza la consulta a la bb.dd y obtiene los resultados
                let sitios = backendless.persistenceService.of(Sitio.ofClass()).find(query)
                
                let currentPage = sitios.getCurrentPage()
                for sitio in currentPage as! [Sitio] {
                    valoracionMediaSitio = sitio.valoracionMedia
                    }
                    
            
                
        
            // recalcular la valoracion media en función de si el usuario ya había valorado o no el sitio

            if (valoracionUsuario > 0) && (valoracionUsuario != Int(valoracionUser.text!))
            {
                // el usuario ya había valorado el sitio
                
                nuevaValoracionMedia = (valoracionMediaSitio * 2) - Double(self.valoracionUsuario)
                
                nuevaValoracionMedia = (nuevaValoracionMedia + Double(self.valoracionUser.text!)!) / 2
                
                // Actualiza la valoración del usuario al sitio.
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // conecta con la instancia actual
                    let backendless = Backendless.sharedInstance()
                    
                    // Actualiza el sitio en la bb.dd.
                    let dataStore = backendless.data.of(Valoracion.ofClass());
                    Types.tryblock({ () -> Void in
                        
                        let result = dataStore.save(self.valoracion) as? Valoracion
                        print ("id objecto: \(result!.objectId)")
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
                    
                    
                })

                
                
                
            }
            else {
                
                // el usuairo no había valorado el sitio anteriormente
                
                nuevaValoracionMedia = (valoracionMediaSitio + Double(self.valoracionUser.text!)!) / 2
                
                // añade la valoración del usuario al sitio.
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let backendless = Backendless.sharedInstance()
                    
                    let user = backendless.userService.currentUser
                    
                    
                    // Obtiene el valor del campo idusuario del usuario actual en un string
                    let idUsuario = user.getProperty("idusuario") as! String
                    
                    let nuevaValoracion = Valoracion()
                    nuevaValoracion.sitio_idSitio = self.sitio!.objectId
                    nuevaValoracion.users_idUsuario = user.objectId
                    nuevaValoracion.valoracion = Int(self.valoracionUser.text!)!
                    
                    
                    let dataStore = backendless.data.of(Valoracion.ofClass());
                    Types.tryblock({ () -> Void in
                        
                        let result = dataStore.save(nuevaValoracion) as? Valoracion
                        print ("id objecto: \(result!.objectId)")
                        
                        self.valoracionUsuario = Int(self.valoracionUser.text!)!
    
                        
                        },
                        catchblock: { (exception) -> Void in
                            print("Server reported an error: \(exception)")
                            print("id usuario: \(idUsuario)")
                            let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                            alertController.addAction(OKAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                    })
                   
                })
                
                
            }
            
            
            // Actualiza la valoración media del sitio
            
            self.sitio?.valoracionMedia = nuevaValoracionMedia
            self.valoracionMedia.text = String(nuevaValoracionMedia)
                      
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
                
     
            })
    }
        else{
            
            valoracionUser.backgroundColor = UIColor.redColor()
            let alertController = UIAlertController(title: "Error", message: "Introduza un valor válido (1-5)", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
       textField.resignFirstResponder()
        return false
        
    }
    
}
