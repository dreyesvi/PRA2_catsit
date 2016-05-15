//
//  MapaSitioViewController.swift
//  catsit
//
//  Created by David Reyes on 13/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit



class MapaSitioViewController: UIViewController, CLLocationManagerDelegate {

    
    
    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var saveLocation: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    
    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //Mostrar indicador de actividad
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = view.center;
        indicador.startAnimating()
        view.addSubview(indicador)
        

    let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted{
            
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        
        startLocationManager()
        mapa.showsUserLocation=true
        
        
        // Parar animacion y volver a permitir interacción
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func startLocationManager(){
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate=self
            // bajo precisión para debugar más rápido
            //locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
            locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
            
        }
    }
    
    func stopLocationManager(){
        
        if isUpdatingLocation{
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            isUpdatingLocation=false
            
        }
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print ("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location==nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
            print("Got the desired accuracy")
            
        /*    let locValue : CLLocationCoordinate2D = manager.location!.coordinate;
           
            let long = locValue.longitude;
            let lat = locValue.latitude;
            print(long);
            print(lat);
            let loadlocation = CLLocationCoordinate2D(
                latitude: lat, longitude: long
                
            )     
            
            mapa.centerCoordinate = loadlocation;
          */
            
            
           // let location = locations.last! as CLLocation
            
            let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapa.setRegion(region, animated: true)
            
            location=newLocation
            
            stopLocationManager()
            
            // Activa el botón guardar
            saveLocation.enabled=true
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
