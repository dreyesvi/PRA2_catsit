//
//  FotoPublicaViewController.swift
//  catsit
//
//  Created by David Reyes on 14/6/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class FotoPublicaViewController: UIViewController {

    
    @IBOutlet weak var foto: UIImageView!
    
    // variable para pasar la imagen por parámetro
    var imagen: Imagen?
    
    
    
    /*
     Si por parámetro se le ha pasado la dirección web de la imagen se recupera de backendless y se carga en el UIImage.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imagen?.imagen != nil {
            // si se ha pasado una imagen por parámetro se recupera de backendless
            if let url  = NSURL(string: imagen!.imagen!),
                data = NSData(contentsOfURL: url)
            {
                self.foto.image = UIImage(data: data)!
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    
    
}
