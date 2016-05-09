//
//  SitioCell.swift
//  catsit
//
//  Created by David Reyes on 9/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import Foundation

class SitioCell: UITableViewCell{
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!   
    @IBOutlet weak var imagen: UIImageView!
    
    
    var sitio: Sitio! {
        didSet {
            nombreLabel.text = sitio.nombre
            descripcionLabel.text = sitio.descripcion
            
        }
    }
    
    
}