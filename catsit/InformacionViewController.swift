//
//  InformacionViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class InformacionViewController: UIViewController {
    
    @IBOutlet weak var imagen: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let imagenView = UIImageViewAsync(frame: CGRectMake(0, 0, 400, 400))
        
        //imagenView.downloadImage("https://api.backendless.com/66D4C758-07DB-D75A-FFB5-050DBAFB7F00/v1/files/FotosSitios/2.jpg")
        
        //let url = NSURL(fileURLWithPath: "")
        //let data = NSData(contentsOfURL: url)
        //imagen.image = UIImage(data: data!)
        
        if let url  = NSURL(string: "https://api.backendless.com/66D4C758-07DB-D75A-FFB5-050DBAFB7F00/v1/files/FotosSitios/2.jpg"),
            data = NSData(contentsOfURL: url)
        {
            imagen.image = UIImage(data: data)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
