//
//  EditarSitioTableViewController.swift
//  catsit
//
//  Created by David Reyes on 14/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class EditarSitioTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    
    
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
    
    
    
    
    // variable para guardar los datos del nuevo sitio
    var sitio: Sitio?
    // variable para guardar los datos de localizacion
    var localizaSitio: GeoPoint?
    
    var isEditingMode = false
    
    // Array con las fotos de un sitio
    var fotosArray:[String] = []
    var imagenesArray:[UIImage] = []
    var arrayImagenes:[Imagen]=[]
    
    var celdaSeleccionada = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        
       
        titulo.title = sitio?.nombre
        descripcionTextView.text = sitio?.descripcion
        
        if sitio!.localizacion != nil{
                let location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(sitio!.localizacion!.latitude!),
                longitude: CLLocationDegrees(sitio!.localizacion!.longitude!))
        
                let span = MKCoordinateSpan(latitudeDelta: 0.005,longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location, span: span)
        
                mapa.setRegion(region, animated: true)
        
                let nota = MKPointAnnotation()
                nota.coordinate = location
                nota.title = sitio?.nombre
        
                mapa.addAnnotation(nota)
            
                mapa.hidden=false
                mensajeMapa.hidden=true
             }
        else{
            mapa.hidden=true
            mensajeMapa.hidden=false
        }
        
           // leer todas las fotos del sitio
        
                    let backendless = Backendless.sharedInstance()
        
       
                    // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
                    let query = BackendlessDataQuery()
                    let whereClause = "idUsuario = '\(sitio!.usuario_idUsuario!)' and idSitio = '\(sitio!.nombre!)'"
                    query.whereClause = whereClause
        
                    Types.tryblock({ () -> Void in
            
                            // realiza la consulta a la bb.dd y obtiene los resultados
                            let sitios = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                            let currentPage = sitios.getCurrentPage()
            
                        if currentPage.count==0 {
                         
                            //Si no hay imagenes asociadas al sitio se oculta el CollectionView y se muestra
                            // un botón para añadir fotos
                            
                            self.coleccionFotos.hidden=true
                            self.addFotos.hidden=false
                            
                            
                            
                        }
                        else
                        {
                            
                            self.coleccionFotos.hidden=false
                            self.addFotos.hidden=true
                            
                        
                            // Carga la información de las imágenes en un array
                            for imagen in currentPage as! [Imagen] {
                                    self.fotosArray.append(imagen.imagen!)
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
                        })

        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    @IBAction func editButton(sender: UIBarButtonItem) {
        
        if isEditingMode
        {
            
            
            // Pulsa botón "Done" se muestra el
            // mapa y se oculta el boton
            obtenerLocalizacion.hidden = true
            mapa.hidden = false
            descripcionTextView.editable = false
            editarSitio.title = "Edit"
            isEditingMode = false
            
            let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            //Mostrar indicador de actividad
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
            indicador.center = self.view.center;
            self.view.addSubview(indicador)
            self.view.bringSubviewToFront(indicador)
            indicador.hidden=false
            indicador.startAnimating()
            print(indicador)

            
            // Se actualizan los datos
            
            let backendless = Backendless.sharedInstance()
            
            //let user = backendless.userService.currentUser
            
            
            sitio?.descripcion=descripcionTextView.text
            if localizaSitio != nil{
                sitio?.localizacion=localizaSitio
            }
            
            
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
                            
            })
            
            
            // Parar animacion y volver a permitir interacción
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            indicador.stopAnimating()
            
            
            
        }
        else
        {
            
            // Pulsa el botón editar
            // Oculta el mapa y muestra el botón para llamar a la pantalla de localización
            
            obtenerLocalizacion.hidden = false
            mapa.hidden = true
            descripcionTextView.editable = true
            editarSitio.title = "Done"
            isEditingMode = true
            
         

            
            
            
        }
    }
    
  
    @IBAction func saveLocalizacion(segue:UIStoryboardSegue) {
        
        
        if let MapaSitioViewController = segue.sourceViewController as? MapaSitioViewController {
            
            if let location = MapaSitioViewController.location {
                
                //Actualiza la localización del sitio
                localizaSitio = GeoPoint(point: GEO_POINT(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude), categories: nil)
                print("localización guardada: \(location.coordinate.latitude) \(location.coordinate.longitude)")
                
            }
        }
        
    }

    
    @IBAction func borrarButton(sender: UIBarButtonItem) {
        
        
        let refreshAlert = UIAlertController(title: "Delete", message: "Se borrarán todos los datos del Sitio", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
            self.performSegueWithIdentifier("deleteEditarSitio", sender: self)

            }))
            
            refreshAlert.addAction(UIAlertAction(title: "CANCEL", style: .Cancel, handler: { (action: UIAlertAction!) in
                
                
                
                
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)

        
        
    }
   
    
   func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return fotosArray.count
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CellFotoCollectionViewCell
        
        let imagen = fotosArray[indexPath.row]
        
        if let url  = NSURL(string: imagen),
            data = NSData(contentsOfURL: url)
        {
            cell.foto.image = UIImage(data: data)
        }
        
               
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        celdaSeleccionada = indexPath.row
        
        //let image = self.imagenesArray[indexPath.row]
        
                   // myVC.foto = UIImageView(image: image)
                   // myVC.foto.image = image
                  //  self.presentViewController(myVC, animated: true, completion: nil)
        
    }
    
    // Pasa parámetros a otros View Controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verDetalleFoto" {
            
            //let cell = sender as! UITableViewCell // or your cell subclass
            //let indexPath = self.tableView.indexPathForCell(cell)
            
            // pasa como parámetro el identificador del nuevo sitio a la pantalla de fotos
            
            
            let nav = segue.destinationViewController as! FotoViewController
            //let addEventViewController = nav.topViewController as! FotoViewController
            
           // let image = self.imagenesArray[celdaSeleccionada]
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

    @IBAction func borrarFotoSegue(segue:UIStoryboardSegue) {
        
        
        // Se ha borrado una imagen se actualiza el collectionView
      
        
        fotosArray.removeAtIndex(celdaSeleccionada)
        coleccionFotos.reloadData()
        
        
        
        
    }
    
    
    @IBAction func refrescarFotos(sender: UIBarButtonItem) {
        
        
        //Mostrar indicador de actividad
   /*     UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        //indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        //indicador.center = self.view.center;
        //self.view.addSubview(indicador)
        //self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        print(indicador)*/
        
        // Borra las fotos del array de fotos
        
        self.fotosArray.removeAll()
        self.arrayImagenes.removeAll()
        self.imagenesArray.removeAll()
        
        
        // leer todas las fotos del sitio
        
        let backendless = Backendless.sharedInstance()
        
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
        let query = BackendlessDataQuery()
        let whereClause = "idUsuario = '\(sitio!.usuario_idUsuario!)' and idSitio = '\(sitio!.nombre!)'"
        query.whereClause = whereClause
        
        Types.tryblock({ () -> Void in
            
            // realiza la consulta a la bb.dd y obtiene los resultados
            let sitios = backendless.persistenceService.of(Imagen.ofClass()).find(query)
            let currentPage = sitios.getCurrentPage()
            
            if currentPage.count==0 {
                
                //Si no hay imagenes asociadas al sitio se oculta el CollectionView y se muestra
                // un botón para añadir fotos
                
                self.coleccionFotos.hidden=true
                self.addFotos.hidden=false
                
                
                
            }
            else
            {
                
                self.coleccionFotos.hidden=false
                self.addFotos.hidden=true
                
                
                // Carga la información de las imágenes en un array
                for imagen in currentPage as! [Imagen] {
                    self.fotosArray.append(imagen.imagen!)
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
        })
        

        
        
        
        
        
        coleccionFotos.reloadData()
        
        // Parar animacion y volver a permitir interacción
       /* UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
        indicador.hidden=true*/
    }
    
    
    
    
    
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
