//
//  MapaViewController.swift
//  catsit
//
//  Created by David Reyes on 3/4/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class MapaViewController: UIViewController {
    
    
    
    @IBOutlet weak var listadoMapaButton: UIBarButtonItem!
    
    @IBOutlet weak var vistaListadoTableViewController: UIView!
    
    @IBOutlet weak var vistaMapaViewController: UIView!
    
    @IBOutlet weak var filtroRadioKm: UISlider!
   
    
    @IBOutlet weak var numKmLabel: UITextField!
    
    @IBAction func filtroradioKm(sender: AnyObject) {
        
        numKmLabel.text = String(Int(round(filtroRadioKm.value)))
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
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
        }
        
            
        
        
    }
    
    
}