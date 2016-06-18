//
//  Sitio.swift
//  catsit
//
//  Created by David Reyes on 9/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import Foundation

class Sitio : NSObject {
    
    var objectId: String?
    var descripcion: String?
    var direccion: String?
    var localizacion: GeoPoint?
    var nombre: String?
    var pais: String?
    var provincia: String?
    var usuario_idUsuario: String?
    var descRecortada: String?
    var valoracionMedia: Double=0
   
    override init(){
        
    }
    
    
}