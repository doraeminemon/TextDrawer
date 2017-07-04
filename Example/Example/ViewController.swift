//
//  ViewController.swift
//  Example
//
//  Created by Remi Robert on 17/07/15.
//  Copyright (c) 2015 Remi Robert. All rights reserved.
//

import UIKit
import TextDrawer

class ViewController: UIViewController {
    
    @IBOutlet var containerControlView: UIView!
    @IBOutlet var drawTextView: TextDrawer!
    @IBOutlet var imageViewBackground: UIImageView!
    
    @IBAction func changeTextColor(_ sender: AnyObject) {
        drawTextView.textColor = (sender as! UIButton).backgroundColor
    }
    
    @IBAction func changeBackgroundColor(_ sender: AnyObject) {
        drawTextView.textBackgroundColor = (sender as! UIButton).backgroundColor
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawTextView.textBackgroundColor = UIColor.clear
        drawTextView.textColor = .white
        drawTextView.text = "TextDrawer"
        self.view.bringSubview(toFront: containerControlView)
    }

    @IBAction func renderImage(_ sender: AnyObject) {
         //drawTextView.renderTextOnImage(imageViewBackground.image!)
        let image = drawTextView.renderTextOnView(imageViewBackground)
        self.performSegue(withIdentifier: "previewSegue", sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
            (segue.destination as! PreviewViewController).image = sender as? UIImage
        }
    }
}
