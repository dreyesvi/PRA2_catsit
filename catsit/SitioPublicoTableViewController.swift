//
//  SitioPublicoTableViewController.swift
//  catsit
//
//  Created by David Reyes on 14/6/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class SitioPublicoTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

   
    @IBOutlet weak var coleccionFotos: FotosCollectionView!
    // variables para acceder a los componentes de la vista
 
    @IBOutlet weak var cancelSitio: UIBarButtonItem!
    @IBOutlet weak var titulo: UINavigationItem!
    @IBOutlet weak var descripcionTextView: UITextView!
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var obtenerLocalizacion: UIButton!
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
