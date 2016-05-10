//
//  DetalleSitioViewController.swift
//  catsit
//
//  Created by David Reyes on 9/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class DetalleSitioViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var descripcionTextView: UITextView!
    
    
    @IBOutlet weak var gestionarFotos: UIButton!
    
    @IBOutlet weak var obtenerUbicacion: UIButton!
    
    // variable para guardar los datos del nuevo sitio
    var sitio: Sitio?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Cuando se pulsa la tecla siguiente se pasa el foco al campo descripción
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
     
        case nombreTextField:
        
            descripcionTextView.becomeFirstResponder()
            
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    // Cuando se pulsa la tecla enter en el campo descripción se esconde el teclado
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "saveDetalleSitio" {
            
            let backendless = Backendless.sharedInstance()
            
            let user = backendless.userService.currentUser
            
            let idSitio = Int(rand())
            
            // Obtiene el valor del campo idusuario del usuario actual en un string
            let idUsuario = user.getProperty("idusuario") as! String
            
            //sitio = Sitio(idSitio: idSitio, nombre: nombreTextField.text!, descripcion: descripcionTextView.text, idUsuario: idUsuario)
            sitio = Sitio()
            sitio?.nombre=nombreTextField.text
            sitio?.descripcion=descripcionTextView.text
            sitio?.idSitio=idSitio
            sitio?.usuario_idUsuario=idUsuario
            
            let dataStore = backendless.data.of(Sitio.ofClass());
            Types.tryblock({ () -> Void in
            
                    let result = dataStore.save(self.sitio) as? Sitio
                    print ("id objecto: \(result!.objectId)")
                    print("Sitio guardado con id: \(idSitio)")
                },
                           catchblock: { (exception) -> Void in
                            print("Server reported an error: \(exception)")
                            print("id sitio: \(idSitio)")
                            print("id usuario: \(idUsuario)")
                            
            })

            
        }
    }
    

    
    
    
    
    // MARK: - Table view data source

 /*   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    */
    
    
    
    
    
    
    
    
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
