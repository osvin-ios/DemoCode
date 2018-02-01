//
//  MoversOnRouteViewController.swift
//  Movers On Demand
//
//  Created by osvinuser on 17/08/17.
//  Copyright © 2017 Ios. All rights reserved.
//

import UIKit

class MoversOnRouteViewController: UIViewController {

    @IBOutlet weak var carName_label: UILabel!
    @IBOutlet weak var driverName_label: UILabel!
    @IBOutlet weak var driverImage_imageView: ImageViewDesign!
    @IBOutlet weak var pickupDestinationLocation_label: UILabel!
    @IBOutlet weak var pickupSourceLocation_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBarSetUp()
 
    }

    @IBAction func navigationBack_buttonAction(_ sender: Any) {
         self.navigationBackAndCancelButtonAction()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callDriver_buttonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "segueToReciept", sender: self)
    }

    @IBAction func cancelMover_buttonAction(_ sender: Any) {
        
    }
}
