//
//  HacerFotoViewController.swift
//  catsit
//
//  Created by David Reyes on 11/5/16.
//  Copyright © 2016 David Reyes. All rights reserved.
//

import UIKit

class HacerFotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet var imagenFoto: UIImageView!
   
    
    var imagePicker: UIImagePickerController!
    
    @IBAction func hacerFoto(sender: AnyObject) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    

    
    @IBAction func seleccionarFoto(sender: AnyObject) {
        
        
        //let fotoPicker = UIImagePickerController()
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    func imagePickerController(picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imagenFoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
