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
    
    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
        //Mostrar indicador de actividad
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = view.center;
        indicador.startAnimating()
        view.addSubview(indicador)
        
        let backendless = Backendless.sharedInstance()
      
        let user = backendless.userService.currentUser
        
        // Obtiene el valor del campo idusuario del usuario actual en un string
        let idUsuario = user.getProperty("idusuario") as! String
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
        let query = BackendlessDataQuery()
        let whereClause = "usuario_idUsuario = '\(idUsuario)'"
        query.whereClause = whereClause
        
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
        
        cell.sitio = sitio
        
        //cell.imagen = obtener1ImagenSitio( sitio.idSitio , idUsuario: (sitio.usuario_idUsuario)!)
        
        let backendless = Backendless.sharedInstance()
        
        
        // Prepara una consulta a la tabla sitio filtrando solo los sitios del usuario
        let query = BackendlessDataQuery()
        let whereClause = "idUsuario = '\(sitio.usuario_idUsuario!)' and idSitio='\(sitio.nombre!)'"
        query.whereClause = whereClause
        
        Types.tryblock({ () -> Void in
            
            // realiza la consulta a la bb.dd y obtiene los resultados
            let imagenes = backendless.persistenceService.of(Imagen.ofClass()).find(query)
            let currentPage = imagenes.getCurrentPage()
            
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
    
 
    
    
}