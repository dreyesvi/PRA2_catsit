//
//  VistaMapaViewController.swift
//  catsit
//
//  Created by David Reyes on 30/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class VistaMapaViewController: UIViewController, CLLocationManagerDelegate {

    
   
    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var zoomStepper: UIStepper!
    
    // variables para localizacion
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?

    // Variable que almacena todos los sitios.
    var sitiosArray:[Sitio] = []

    
    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()

    
    @IBAction func didValueChangedZoom(sender: UIStepper) {
        
        let userLocation = mapa.userLocation
        
        
        let region = MKCoordinateRegion(center: userLocation.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1-zoomStepper.value, longitudeDelta: 1-zoomStepper.value))
        
        mapa.setRegion(region, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configura el indicador de actividad
        indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = view.center;
        view.addSubview(indicador)
        
        
      
        
        
        
        // Verifica si el usuario tiene permisos para acceder a la localización
        // En el caso de que no tenga lo solicita al usuario
/*        let authStatus = CLLocationManager.authorizationStatus()
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
            mapa.showsUserLocation=true
            
     
        }

        */
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        super.viewDidAppear(true)
        

        actualizaMapa()
        
      
        
    }
    
    
   
    
    
    
    func actualizaMapa()
    {
        
        // Accede al array de sitios ya leido en el ViewController padre
        let VCpadre = self.parentViewController as! MapaViewController
        
        let newLocation = VCpadre.location
        
        if newLocation != nil {
            
            
            
            let center = CLLocationCoordinate2D(latitude: newLocation!.coordinate.latitude, longitude: newLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            self.mapa.setRegion(region, animated: true)
            
        }
        
        let allAnnotations = self.mapa.annotations
        self.mapa.removeAnnotations(allAnnotations)
        
        mapa.showsUserLocation=true
        
        
        for sitio in VCpadre.sitiosArray{
            
            if sitio.localizacion != nil {
                
                let nota = MKPointAnnotation()
                
                // convierte un GeoPoint a formato CLLocation
                let location = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(sitio.localizacion!.latitude),
                    longitude: CLLocationDegrees(sitio.localizacion!.longitude))
                
                nota.coordinate = location
                nota.title = sitio.nombre
                self.mapa.addAnnotation(nota)
                print("nota: \(nota.title)")
                
            }
        }

        
    }
    
    
    /*
     Define los parámetros de precisión de la localización y la inicia.
     */
 /*   func startLocationManager(){
        
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
    */
    
    
    /*
     Para el servicio de localización
     */
/*    func stopLocationManager(){
        
        if isUpdatingLocation{
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            isUpdatingLocation=false
        }
    }
*/
  
    /*
     Lee la localización y guarda la mejor obtenida hasta conseguir una localización con la precisión definida.
     Muestra la posición en el mapa y modifica la vista del mapa para centrarla.
     Para los servicios de localización cuando lo consigue. Activa el botón “Save”.
     */
/*    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
        self.indicador.startAnimating()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
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
                
                let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                self.mapa.setRegion(region, animated: true)
                
            }
            
            // se consigue una localización con la precisión definida
            if newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy{
                print("se ha conseguido la precisión definida")
                
                let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                self.mapa.setRegion(region, animated: true)
                
        
                // se guarda la localización recibida en la variable de clase
                self.location=newLocation
                
                // se para la localización
                self.stopLocationManager()
                
 
                self.indicador.stopAnimating()
                
                // Accede al array de sitios ya leido en el ViewController padre
                let VCpadre = self.parentViewController as! MapaViewController
                
                for sitio in VCpadre.sitiosArray{
                    
                    if sitio.localizacion != nil {

                        let nota = MKPointAnnotation()

                        // convierte un GeoPoint a formato CLLocation
                    let location = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(sitio.localizacion!.latitude),
                        longitude: CLLocationDegrees(sitio.localizacion!.longitude))

                     nota.coordinate = location
                     nota.title = sitio.nombre
                     self.mapa.addAnnotation(nota)
                     print("nota: \(nota.title)")
  
                    }
                }
                
                
                
            }
            
        })
    }
  */
    
    /*
     Se ejecuta cuando se detecta un error de localización. Se muestra un mensaje al usuario.
     */
/*    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
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

    */
    

}
