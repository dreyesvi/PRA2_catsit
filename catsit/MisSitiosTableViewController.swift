//
//  MisSitiosTableViewController.swift
//  catsit
//
//  Created by David Reyes on 8/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import Foundation




class MisSitiosTableViewController: UITableViewController {
    
     var sitiosArray:[Sitio] = []
     var celdaSeleccionada = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
        let query = BackendlessDataQuery()
        let whereClause = "usuario_idUsuario = '\(idUsuario)'"
        query.whereClause = whereClause
        
        // lee los datos relacionados de GeoPoint
        let queryOptions = QueryOptions()
        queryOptions.addRelated("localizacion")
        query.queryOptions = queryOptions
        
        
        Types.tryblock({ () -> Void in
        
                // realiza la consulta a la bb.dd y obtiene los resultados
                let sitios = backendless.persistenceService.of(Sitio.ofClass()).find(query)
                let currentPage = sitios.getCurrentPage()
        
                // Carga la información de los sitios en un array
                for sitio in currentPage as! [Sitio] {
                        self.sitiosArray.append(sitio)
            
                    }
                },
               catchblock: { (exception) -> Void in
              print("Server reported an error: \(exception)")
              print (whereClause)
            })
        
        // Parar animacion y volver a permitir interacción
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
        indicador.removeFromSuperview()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
  
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitiosArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("celdaSitio", forIndexPath: indexPath) as! SitioCell
        
        let sitio = sitiosArray[indexPath.row] as Sitio
        
        
        // obtiene una versión recortada de la descripción max. 60 caracteres
        let longdescripcion = sitio.descripcion?.characters.count
        if (longdescripcion > 60) {
            let descrecortada = sitio.descripcion![sitio.descripcion!.startIndex...sitio.descripcion!.startIndex.advancedBy(60)]
            sitio.descripcion=descrecortada
           print ("descripcion recortada: \(descrecortada)")
        }
       
        cell.sitio = sitio
        
        
        let backendless = Backendless.sharedInstance()
        
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
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
            cell.imagen.image = UIImage()
            
            // Obtiene la primera imagen
            for img in currentPage as! [Imagen] {
                
                if let url  = NSURL(string: img.imagen!),
                    data = NSData(contentsOfURL: url)
                {
                    cell.imagen.image = UIImage(data: data)
                }
            
                break
                
                
            }
            },
                       catchblock: { (exception) -> Void in
                        print("Server reported an error: \(exception)")
                        print (whereClause)
        })
        
        return cell
    }
    

    @IBAction func cancelEditarSitioTableViewController(segue:UIStoryboardSegue) {
        
        
        
        let indexPath = NSIndexPath(forRow: celdaSeleccionada, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        
    }
    
    
    @IBAction func deleteEditarSitioTableViewController(segue:UIStoryboardSegue) {
        
        
        
            
            
            
        // Si se pulsa "OK" se borran las imagenes y el sitio
        
        if let editarSitioTableViewController = segue.sourceViewController as? EditarSitioTableViewController {
            
            if let sitio = editarSitioTableViewController.sitio {
                
                let backendless = Backendless.sharedInstance()
                
                let user = backendless.userService.currentUser
                
                
                var error: Fault?
                
                // Borrar imagenes del sitio
                
                // Path donde se guardan las fotos en backendless
                let path = "FotosSitios/"
                
                // Obtiene el valor del campo idusuario del usuario actual en un string
                let idUsuario = user.getProperty("idusuario") as! String
                
                // Prepara una consulta a la tabla imagen filtrando solo las fotos del nuevo sitio del usuario
                let query = BackendlessDataQuery()
                let whereClause = "idUsuario = '\(idUsuario)' and idSitio='\(sitio.nombre)'"
                query.whereClause = whereClause
                
                let dataStore = backendless.data.of(Imagen.ofClass());
                
                Types.tryblock({ () -> Void in
                    
                    // realiza la consulta a la bb.dd y obtiene los resultados
                    let imagenes = backendless.persistenceService.of(Imagen.ofClass()).find(query)
                    let currentPage = imagenes.getCurrentPage()
                    
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
                                }
                        
                        }
                    
                    
                    },
                               
                         catchblock: { (exception) -> Void in
                         print("Server reported an error: \(exception as! Fault)")
                        }
                )

                
                // Borrar sitio
                
                // Prepara una consulta a la tabla sitio filtrando solo el sitio a borrar del usuario
               /* let querySitio = BackendlessDataQuery()
                let whereClauseSitio = "idUsuario = '\(idUsuario)' and nombre='\(sitio.nombre)'"
                querySitio.whereClause = whereClauseSitio*/
                

                let dataStoreSitio = backendless.data.of(Sitio.ofClass());
                Types.tryblock({ () -> Void in
                    
                    // Borra el sitio
                    let resultbbddsitio = dataStoreSitio.remove(sitio, fault: &error)
                    if error == nil {
                        print("Sitio borrado de la bb.dd: \(sitio.nombre) codigo: \(resultbbddsitio)")
                    }
                    else {
                        print("Server reported an error: \(error)")
                    }
                    
                    },
                               
                               catchblock: { (exception) -> Void in
                                print("Server reported an error: \(exception as! Fault)")
                    }
                )
                
              
                // Elimina el sitio del array y actualiza el tableView
                self.sitiosArray.removeAtIndex(self.celdaSeleccionada)
                self.tableView.reloadData()
            
            }
            
        }
        
                
        
    }
    
    
    @IBAction func cancelToSitioViewController(segue:UIStoryboardSegue) {
        
    }
    @IBAction func saveDetalleSitio(segue:UIStoryboardSegue) {
        
        
        if let DetalleSitioViewController = segue.sourceViewController as? DetalleSitioViewController {
            
            if let sitio = DetalleSitioViewController.sitio {
                //Añade el nuevo sitio al array de sitios
                sitiosArray.append(sitio)
                
                // Actualiza el tableView con el nuevo sitio
                let indexPath = NSIndexPath(forRow: sitiosArray.count-1, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            }
            
        }
        
        
    }
    

    
    // Pasa parámetros a otros Vidw Controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editarSitio" {
            
            let cell = sender as! UITableViewCell // or your cell subclass
            let indexPath = self.tableView.indexPathForCell(cell)
            
            // pasa como parámetro el identificador del nuevo sitio a la pantalla de fotos
            
            
            let nav = segue.destinationViewController as! UINavigationController
            let addEventViewController = nav.topViewController as! EditarSitioTableViewController
            
            let sitio = sitiosArray[indexPath!.row] as Sitio
            
            addEventViewController.sitio = sitio
            
            celdaSeleccionada = indexPath!.row
        }
            
    }
    
    
 
    
    
}