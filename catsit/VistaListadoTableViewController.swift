//
//  VistaListadoTableViewController.swift
//  catsit
//
//  Created by David Reyes on 30/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class VistaListadoTableViewController: UITableViewController {

    // Cache de imágenes
    var imageCache = [String:UIImage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // Actualiza la tabla cuando se vuelve a mostrar la pantalla.
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
        
    }

    // Define solo una sección en la tabla
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Define como número de filas de la tabla el tamaño del array de la vista padre.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Accede al array de sitios ya leido en el ViewController padre
        let VCpadre = self.parentViewController as! MapaViewController
        return VCpadre.sitiosArray.count
     }

    
    // Rellena las filas de la tabla, a partir del array de sitios contenido en el padre.
    // Consulta en la base de datos las imágenes del sitio y las guarda en el array de imágenes para mejorar la eficiencia
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SitioMapaCell

        // Accede al array de sitios ya leido en el ViewController padre
        let VCpadre = self.parentViewController as! MapaViewController

        let sitio = VCpadre.sitiosArray[indexPath.row] as Sitio
        
        cell.nombre.text = sitio.nombre
        cell.descripcion.text = sitio.descripcion
        cell.valoracionMedia.text = String(sitio.valoracionMedia)
        
        
        // obtiene una versión recortada de la descripción max. 60 caracteres
        let longdescripcion = sitio.descripcion?.characters.count
        if (longdescripcion > 30) {
            let descrecortada = sitio.descripcion![sitio.descripcion!.startIndex...sitio.descripcion!.startIndex.advancedBy(30)]
            cell.descripcion.text = descrecortada
            //print ("descripcion recortada: \(descrecortada)")
        }
        
        
        //Mostrar indicador de actividad
        let indicador = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicador.center = self.view.center;
        self.view.addSubview(indicador)
        self.view.bringSubviewToFront(indicador)
        indicador.hidden=false
        indicador.hidesWhenStopped=true
        
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
     Cuando se selecciona una fila de la tabla se hace un segue “sitioPublico” a “SitioPublicoTableViewController”
     se pasa como parámetro el sitio.
     -	Verifica que el segue sea “sitioPublico”
     -	Se guarda el número de fila seleccionada.
     -	Pasa como parámetro “Sitio” al ViewController “SitioPublicoTableViewController”.
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "sitioPublico" {
            
            // número de fila seleccionado
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            
            // pasa como parámetro los datos del sitio
            let nav = segue.destinationViewController as! UINavigationController
            let addEventViewController = nav.topViewController as! SitioPublicoTableViewController
            
            // Accede al array de sitios ya leido en el ViewController padre
            let VCpadre = self.parentViewController as! MapaViewController
            
            let sitio = VCpadre.sitiosArray[indexPath!.row] as Sitio
            addEventViewController.sitio = sitio
        }
    }

    /*
     Unwind que se llama cuando el usuario pulsa el botón “cerrar” en la pantalla “SitioPublicoTableViewController”.
     */
    @IBAction func cancelSitioPublicoTableViewController(segue:UIStoryboardSegue) {
        
    
    
    }
    

   

}
