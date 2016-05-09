//
//  Sitio.swift
//  catsit
//
//  Created by David Reyes on 9/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import Foundation

class Sitio : NSObject {
    
    var objectId : String?
    var created : NSDate?
    var updated : NSDate?
    var idSitio: Int=0
    var nombre: String?
    var descripcion: String?
    var direccion: String?
    var provincia: String?
    var pais: String?
    var latitud: GeoPoint?
    var longitud: GeoPoint?
    var usuario_idUsuario: String?
   
    
}