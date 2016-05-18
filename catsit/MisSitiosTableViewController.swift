//
//  MisSitiosTableViewController.swift
//  catsit
//
//  Created by David Reyes on 8/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import Foundation

class MisSitiosTableViewController: UITableViewController {
    
    
    // Variable que almacena el listado de sitios de un usuario.
    var sitiosArray:[Sitio] = []
    
    // Fila de la tabla que selecciona el usuario.
    var celdaSeleccionada = 0
    
    var sitioSeleccionado = " "
    
    // Cache de imágenes
    var imageCache = [String:UIImage]()
    
    /*
     Conecta con backendless para consultar la lista de sitios
     del usuario activo. Carga la lista en la variable “sitiosArrray”.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        // Conecta con la instancia de backendless que se ha logineado el usuario
        let backendless = Backendless.sharedInstance()
      
        // recupera el usuario
        let user = backendless.userService.currentUser
        
        // Obtiene el valor del campo idusuario del usuario actual en un string
        let idUsuario = user.getProperty("idusuario") as! String
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
        let query = BackendlessDataQuery()
        let whereClause = "usuario_idUsuario = '\(idUsuario)'"
        query.whereClause = whereClause
        
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
                    print (whereClause)
                
                    let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
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
     Devuelve el número de filas que tiene la tabla, que es el número de elementos del array de sitios
     (sitiosArray) cargado al inicio.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitiosArray.count
    }
    

    
    /*
     Dibuja una fila de tipo “celdaSitio/SitioCell” en la tabla.
     -	Recupera una fila del array de sitios y lo asigna a la celda prototipo asociada.
     -	Recorta la descripción y la asigna como descripción del sitio.
     -	Conecta con backendless para recuperar una imagen del sitio y mostrarla en la fila.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true
        
        
        // variable de tipo Sitiocell asociada a la celda prototipo
        let cell = tableView.dequeueReusableCellWithIdentifier("celdaSitio", forIndexPath: indexPath) as! SitioCell
        
        // Datos del sitio a mostrar en la tabla
        let sitio = sitiosArray[indexPath.row] as Sitio
        
        
        // obtiene una versión recortada de la descripción max. 60 caracteres
        sitio.descRecortada = sitio.descripcion
        let longdescripcion = sitio.descripcion?.characters.count
        if (longdescripcion > 60) {
            let descrecortada = sitio.descripcion![sitio.descripcion!.startIndex...sitio.descripcion!.startIndex.advancedBy(60)]
            sitio.descRecortada=descrecortada
            print ("descripcion recortada: \(descrecortada)")
        }
       
        // asigna a la celda prototipo los valores del sitio
        cell.sitio = sitio
        
        // Inicializa la imagen en blanco
        cell.imagen.image = UIImage(named: "Blank50")
        
        // verifica sila imagen está en la cache de imágenes
        if let imagen = imageCache[sitio.nombre!]{
            
            cell.imagen.image = imagen
        }
        else
        {
        
            
        // activa el símbolo de trabajando...
        indicador.startAnimating()
        
        // ejecuta en modo asincrono la carga de imágenes
        dispatch_async(dispatch_get_main_queue(), {
                
            // Conecta con la instancia de backendless actual
            let backendless = Backendless.sharedInstance()
            
            
            // Prepara una consulta a la tabla imagen filtrando solo las imágenes del sitio del usuario
            let query = BackendlessDataQuery()
            let whereClause = "idUsuario = '\(sitio.usuario_idUsuario!)' and idSitio='\(sitio.nombre!)'"
            query.whereClause = whereClause
            // Solo recupera la primera imagen
            query.queryOptions.pageSize = 1
            
            Types.tryblock({ () -> Void in
                
                // realiza la consulta a la bb.dd y obtiene los resultados
                let imagenes = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                let currentPage = imagenes.getCurrentPage()
                
                //Inizializa la imagen a blanco por si no hay imagenes del sitio
                //cell.imagen.image = UIImage()
                
                if currentPage.count==0
                {
                    self.imageCache[sitio.nombre!] = UIImage(named: "Blank50")
                }
                else
                {
                
                // Obtiene la primera imagen
                for img in currentPage as! [Imagen] {

                    // recupera la imagen a partir de la dirección URL
                    if let url  = NSURL(string: img.imagen!),
                        data = NSData(contentsOfURL: url)
                    {
                                cell.imagen.image = UIImage(data: data)
                                // guarda la imagen en la cache para el sitio
                                self.imageCache[sitio.nombre!] = cell.imagen.image
                    }
                    break
                }
                }
                },
                    catchblock: { (exception) -> Void in
                    // Muestra mensaje en caso de error
                    print("Server reported an error: \(exception)")
                    print (whereClause)
                    
                    let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
            })
                // para el indiciador de trabajando antes de salir del modo asíncrono.
                indicador.stopAnimating()
                })
        }
    
        return cell
    }
    
    
    
    
    /*
     Unwind que se llama cuando el usuario pulsa el botón “Cancel” en la pantalla “Editar Sitio”. 
     Refresca los valores de la fila de la tabla por si ha cambiado o agregado una imagen.
    */
    @IBAction func cancelEditarSitioTableViewController(segue:UIStoryboardSegue) {
        
        // borra la imagen de la celda seleccionada para refrescarla
        let sitio = sitiosArray[celdaSeleccionada] as Sitio
        let indice = self.imageCache.indexForKey(sitio.nombre!)
        self.imageCache.removeAtIndex(indice!)
        
        // Obtiene el indexPath de la celda seleccionada por el usuario
        let indexPath = NSIndexPath(forRow: celdaSeleccionada, inSection: 0)
        // Refresca los valores del sitio por si ha cambiado o se ha borrado.
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    

    
    
    /*
     Unwind manual que se llama cuando se confirma que el usuario quiere borrar toda la información de un sitio.
     -	Elimina el sitio del array de sitios
     -  Actualiza la cache de imagenes
     -	Actualiza la tabla, eliminando la fila que se acabad de borrar.
    */
    @IBAction func deleteEditarSitioTableViewController(segue:UIStoryboardSegue) {
        
        // Si se pulsa "OK" se borran las imagenes y el sitio
        
        if let editarSitioTableViewController = segue.sourceViewController as? EditarSitioTableViewController {
            
            if let sitio = editarSitioTableViewController.sitio {
   
                
                if editarSitioTableViewController.errorDetectado == false
                
                {
                    // Elimina el sitio del array y actualiza el tableView
                    self.sitiosArray.removeAtIndex(self.celdaSeleccionada)
                    
                    // borra la imagen de la cache seleccionada para refrescarla
                    //let sitio = self.sitiosArray[self.celdaSeleccionada] as Sitio
                    let indice = self.imageCache.indexForKey(sitio.nombre!)
                    self.imageCache.removeAtIndex(indice!)
                    
                    self.tableView.reloadData()
                    
                }
                
            }
        }
    }
    
    
    
    
    /*
     Unwind que se llama desde la pantalla de añadir un nuevo sitio “DetalleSitioViewController.swift”.
     Como es un nuevo sitio al cancelar no hace nada.
    */
    @IBAction func cancelToSitioViewController(segue:UIStoryboardSegue) { }
    
    
    
    /*
     Unwind que se llama desde la pantalla de añadir un nuevo sitio “DetalleSitioViewController.swift”.
     -	Añade el nuevo sitio al array de sitios.
     -	Actualiza la tabla con los datos del nuevo sitio.
    */
    @IBAction func saveDetalleSitio(segue:UIStoryboardSegue) {
        
        
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        
        
        if let DetalleSitioViewController = segue.sourceViewController as? DetalleSitioViewController {
        
            if DetalleSitioViewController.errorAlGuardar == false

            {
              if let sitio = DetalleSitioViewController.sitio {
                indicador.startAnimating()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //Añade el nuevo sitio al array de sitios
                    self.sitiosArray.append(sitio)
                
                    // Actualiza el tableView con el nuevo sitio
                    let indexPath = NSIndexPath(forRow: self.sitiosArray.count-1, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                })
                
                indicador.stopAnimating()
               }
            }
        }
    }
    

    
    
    /*
     Cuando se selecciona una fila de la tabla se hace un segue “EditarSitio” a “EditarSitioTableViewController” 
     se pasa como parámetro el sitio.
     -	Verifica que el segue sea “editarSitio”
     -	Se guarda el número de fila seleccionada.
     -	Pasa como parámetro “Sitio” al ViewController “EditarSitioTableViewController”.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editarSitio" {
            
            // número de fila seleccionado
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            celdaSeleccionada = indexPath!.row
            
            
            // pasa como parámetro los datos del sitio 
            let nav = segue.destinationViewController as! UINavigationController
            let addEventViewController = nav.topViewController as! EditarSitioTableViewController
            let sitio = sitiosArray[indexPath!.row] as Sitio
            addEventViewController.sitio = sitio
        }
    }
    
}