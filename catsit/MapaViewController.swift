//
//  MapaViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class MapaViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var listadoMapaButton: UIBarButtonItem!
    
    @IBOutlet weak var vistaListadoTableViewController: UIView!
    
    @IBOutlet weak var vistaMapaViewController: UIView!
    
    @IBOutlet weak var filtroRadioKm: UISlider!
   
    
    @IBOutlet weak var numKmLabel: UITextField!
    
    // Variable que almacena todos los sitios.
    var sitiosArray:[Sitio] = []

    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // variables para localizacion
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?

    private var vistaMapaVC: VistaMapaViewController!
    private var vistaListadoTVC: VistaListadoTableViewController!
    
    @IBAction func filtroradioKm(sender: AnyObject) {
        
        numKmLabel.text = String(Int(round(filtroRadioKm.value)))
        
        
    }
    
    
    @IBAction func actualizaDistancia(sender: UIButton) {
        
        actualizaSitiosDistancia()
        
      
        
        self.vistaMapaVC.actualizaMapa()
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? VistaMapaViewController
            where segue.identifier == "vistaMapaSegue" {
            
            self.vistaMapaVC = vc
        }
        
        
        if let vc2 = segue.destinationViewController as? VistaListadoTableViewController
            where segue.identifier == "vistaListadoSegue" {
            
            self.vistaListadoTVC = vc2
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numKmLabel.text = "1"
        
        
        
        // Primero realiza intenta localizar al usuario para saber su posición
        //Configura el indicador de actividad
        indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = view.center;
        view.addSubview(indicador)
        
        // Verifica si el usuario tiene permisos para acceder a la localización
        // En el caso de que no tenga lo solicita al usuario
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Si el usuario deniega la autorización muestra un mensaje de error
        if authStatus == .Denied || authStatus == .Restricted{
            let alert = UIAlertController(title: "Servicios de localización desactivados", message: "Por favor active los servicios de localización para esta app en ajustes", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            // si hay autorización se inicia la localización
            startLocationManager()
        //    mapa.showsUserLocation=true
            
            
        }

        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapListadoMapaButton(sender: UIBarButtonItem) {
        
        if listadoMapaButton.title=="Listado" {
            
            listadoMapaButton.title="Mapa"
            UIView.animateWithDuration(0.5, animations: {
            self.vistaMapaViewController.alpha=0
            self.vistaListadoTableViewController.alpha=1
            })
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
            self.vistaListadoTableViewController.alpha=0
            self.vistaMapaViewController.alpha=1
                })
            listadoMapaButton.title="Listado"
           // self.vistaListadoTVC.tableView.reloadData()
            
        }
        
            
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        Types.tryblock(
            { () -> Void in

            let numerico = Int(textField.text!)

                if (numerico < 0 || numerico > 10)
                {
                    let alertController = UIAlertController(title: "Error", message: "Solo se permiten valores entre 0 y 10", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else{
                    self.filtroRadioKm.value = Float(numerico!)
                }
                
            }, catchblock: { (exception) -> Void in
                
                let alertController = UIAlertController(title: "Error", message: "Solo se permiten valores numéricos entre 0 y 10", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
        })
            
            textField.resignFirstResponder()
               
        return false
        
    }

    /*
     Define los parámetros de precisión de la localización y la inicia.
     */
    func startLocationManager(){
        
        if CLLocationManager.locationServicesEnabled(){
            // Si los servicios de localizacion están activos
            locationManager.delegate=self
            
            // bajo precisión para realizar pruebas más rápido
            locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
            //locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
            
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
        else
        {
            let alert = UIAlertController(title: "Servicios de localización desactivados", message: "Por favor active los servicios de localización para esta app en ajustes", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    /*
     Para el servicio de localización
     */
    func stopLocationManager(){
        
        if isUpdatingLocation{
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            isUpdatingLocation=false
        }
    }
    
    
    /*
     Lee la localización y guarda la mejor obtenida hasta conseguir una localización con la precisión definida.
     Muestra la posición en el mapa y modifica la vista del mapa para centrarla.
     Para los servicios de localización cuando lo consigue. Activa el botón “Save”.
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
        self.indicador.startAnimating()
     //   dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            // obtiene la última localización recibida
            let newLocation = locations.last!
            print ("Nueva localizacion: \(newLocation)")
            
            
            if newLocation.timestamp.timeIntervalSinceNow < -5 {
                
                return
            }
            if newLocation.horizontalAccuracy < 0 {
                
                return
            }
            
            // guarda la mejor localización recibida
            if self.location==nil || self.location!.horizontalAccuracy > newLocation.horizontalAccuracy {
                self.lastLocationError = nil
                self.location = newLocation
                
            //    let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            //    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
               // self.mapa.setRegion(region, animated: true)
                
            }
            
            // se consigue una localización con la precisión definida
            if newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy{
                print("se ha conseguido la precisión definida")
                
            //    let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            //    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
              //  self.mapa.setRegion(region, animated: true)
                
                
                // se guarda la localización recibida en la variable de clase
                self.location=newLocation
                
                // se para la localización
                self.stopLocationManager()
                
                
                
                
                actualizaSitiosDistancia()
                
                
                
                
                
                self.indicador.stopAnimating()
                
                // Accede al array de sitios ya leido en el ViewController padre
              /*  let VCpadre = self.parentViewController as! MapaViewController
                
                for sitio in VCpadre.sitiosArray{
                    
                    if sitio.localizacion != nil {
                        
                        let nota = MKPointAnnotation()
                        
                        // convierte un GeoPoint a formato CLLocation
                        let location = CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(sitio.localizacion!.latitude),
                            longitude: CLLocationDegrees(sitio.localizacion!.longitude))
                        
              //          nota.coordinate = location
              //          nota.title = sitio.nombre
              //          self.mapa.addAnnotation(nota)
              //          print("nota: \(nota.title)")
                        
                    }
                }
                */
                
                
            }
            
 //       })
    }
    
    
    /*
     Se ejecuta cuando se detecta un error de localización. Se muestra un mensaje al usuario.
     */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        let alert = UIAlertController(title: "Error de localización", message: error.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        stopLocationManager()
    }

    func actualizaSitiosDistancia (){
        
        // Conecta con la instancia de backendless que se ha logineado el usuario
        let backendless = Backendless.sharedInstance()
        
        
        // Prepara una consulta a la tabla sitio para leer todos los sitios
        // let query = BackendlessDataQuery()
        
        // indica que obtenga los datos relacionados de localización (GeoPoint)
        // let queryOptions = QueryOptions()
        // queryOptions.addRelated("localizacion")
        // query.queryOptions = queryOptions
        
        Types.tryblock(
            { () -> Void in
                
                let queryOptions = QueryOptions()
                queryOptions.relationsDepth = 1;
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.queryOptions = queryOptions;
                
                dataQuery.whereClause = "distance( \(self.location!.coordinate.latitude), \(self.location!.coordinate.longitude), localizacion.latitude, localizacion.longitude ) < km(\(self.numKmLabel.text!))"
                
                print (dataQuery.whereClause)
                
                let sitios = backendless.persistenceService.find(Sitio.ofClass(), dataQuery:dataQuery) as BackendlessCollection
                
                
                self.sitiosArray.removeAll()
                
                // realiza la consulta a la bb.dd y obtiene la lista de sitios del usuario
                //  let sitios = backendless.persistenceService.of(Sitio.ofClass()).find(query)
                //                     let currentPage = sitios.getCurrentPage()
                
                // Recorre la lista de sitios y carga la información de los sitios en un array
                for sitio in sitios.data as! [Sitio] {
                    //                       for sitio in currentPage as! [Sitio]
                    //                       {
                    self.sitiosArray.append(sitio)
                }
                
                
                
            }, catchblock: { (exception) -> Void in
                // muestra el mensaje de error
                print("Server reported an error: \(exception)")
                
                
                let alertController = UIAlertController(title: "Error", message: exception.message, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default){ (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        })

        
    }
    
}