//
//  VistaMapaViewController.swift
//  catsit
//
//  Created by David Reyes on 30/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class VistaMapaViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
   
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var zoomStepper: UIStepper!
    
    // variables para localizacion
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?

    // Variable que almacena todos los sitios.
    var sitiosArray:[Sitio] = []
 
    // guarda el pin seleccionado en el mapa.
    var selectedAnnotation: MKPointAnnotation!

    // Variable para mostrar el indicador de actividad mientras se está registrando el usuario
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()

    
    
    // Cuando se pulsa el botón de zoom se actualiza la región del mapa a mostrar.
    // se muestra más o menos distancia.
    @IBAction func didValueChangedZoom(sender: UIStepper) {
        
        let userLocation = mapa.userLocation
        let region = MKCoordinateRegion(center: userLocation.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1-zoomStepper.value, longitudeDelta: 1-zoomStepper.value))
        mapa.setRegion(region, animated: true)
        
    }

    // inicializa el indicador de actividad
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configura el indicador de actividad
        indicador.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
        indicador.center = view.center;
        view.addSubview(indicador)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // Se actualiza el mapa cuando se vuelve a mostrar la vista mapa.
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        actualizaMapa()
        
    }
    
   
    
    // Actualiza la región del mapa en función de la localización del usuario
    // Añade la localización de los sitios en el mapa.
    func actualizaMapa()
    {
        
        // Accede al ViewController padre
        let VCpadre = self.parentViewController as! MapaViewController
        
        // obtiene la localización del usuario
        let newLocation = VCpadre.location
        
        // actualiza la región del mapa para centrar la posición del usuario
        if newLocation != nil {
            let center = CLLocationCoordinate2D(latitude: newLocation!.coordinate.latitude, longitude: newLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            self.mapa.setRegion(region, animated: true)
            
        }
        
        // elimina toda las notas que tenga el mapa.
        let allAnnotations = self.mapa.annotations
        self.mapa.removeAnnotations(allAnnotations)
        
        mapa.showsUserLocation=true
        
        
        // muestra los sitios en el mapa
        for sitio in VCpadre.sitiosArray{
            
            if sitio.localizacion != nil {
                let nota = MKPointAnnotation()
                
                // convierte un GeoPoint a formato CLLocation
                let location = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(sitio.localizacion!.latitude),
                    longitude: CLLocationDegrees(sitio.localizacion!.longitude))
                
                nota.coordinate = location
                nota.title = sitio.nombre
                nota.subtitle = "Valoracion: " + String(sitio.valoracionMedia)
                self.mapa.addAnnotation(nota)
                
                print("nota: \(nota.title)")
                
            }
        }

        
    }
    
    // configura para que los puntos seleccionados en el mapa tengan un botón para acceder al detalle.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("sitio")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sitio")
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
           
        } else {
            view?.annotation = annotation
        }
        return view
    }
    
    
    // cuando se pulsa sobre el botón de información de una anotación que representa a un sitio se llama
    // al segue "mapaDetalle" que abre la pantalla para mostrar la información pública del sitio.
    // si el botón pulsado es el de la localización del usuario se muestra un mensaje indicándolo.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            if selectedAnnotation != nil{
            
                performSegueWithIdentifier("mapaDetalle", sender: self)
            }
            else{
                let alert = UIAlertController(title: "Mi Ubicación", message: "Esta es mi localización", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // Cuando se pulsa el botón de una anotación se le pasa los datos del sitio a la pantalla de
    // información pública para mostrarla.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mapaDetalle" {
 
            // pasa como parámetro los datos del sitio
            let nav = segue.destinationViewController as! UINavigationController
            let addEventViewController = nav.topViewController as! SitioPublicoTableViewController
            
            // Accede al array de sitios ya leido en el ViewController padre
            let VCpadre = self.parentViewController as! MapaViewController
            
            // obtener el sitio seleccionado a partir de la anotación seleccionada.
            var encontrado: Bool = false
            var contador:Int = 0;
            
            var sitio = Sitio()
            while (encontrado == false && contador<VCpadre.sitiosArray.count)
            {
                sitio = VCpadre.sitiosArray[contador] as Sitio
                
                if sitio.nombre == selectedAnnotation.title
                {
                    encontrado = true
                    addEventViewController.sitio = sitio
                    
                }
                else
                {
                    contador = contador + 1
                    
                }
            }
            
        }
    }
    
   

}
