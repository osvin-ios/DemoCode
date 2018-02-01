//
//  SelectVehicleViewController.swift
//  Movers On Demand
//
//  Created by osvinuser on 14/08/17.
//  Copyright © 2017 Ios. All rights reserved.
//

import UIKit

class SelectVehicleViewController: UIViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var main_collectionView: UICollectionView!
    @IBOutlet weak var bigImage_imageView: UIImageView!
    @IBOutlet weak var weight_label: UILabel!
    @IBOutlet weak var upeer_view: UIView!
    @IBOutlet weak var size_label: UILabel!
    
    // MARK:- Variables
    var collectionViewDataArray = [SelectVehicleModelClass]()
    var selectedValue : Int = 0
    var noInternetViewObj = NoInternetConnectionView()
    var serverErrorViewObj = ServerErrorView()
    var previousViewDict = Dictionary<String,AnyObject>()
    var dataDict = Dictionary<String,AnyObject>()
    var indexPathArray = [IndexPath]()

    // MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBarSetUp()
        self.getVehicles()

    }
    
    //MARK:- Button Actions
    @IBAction func navigation_backAction(_ sender: Any) {
        self.navigationBackAndCancelButtonAction()
        
    }
    
    @IBAction func continue_buttonAction(_ sender: Any) {
        
        let data = collectionViewDataArray[selectedValue]
        self.performSegue(withIdentifier: "segueToSelectPickupTime", sender: data)
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
//        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    //MARK:- Storyboard Segue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToSelectPickupTime" {
            
            let destinationView = segue.destination as? SelectPickupTimeViewController
            destinationView?.indexValueDataArray = sender as? SelectVehicleModelClass
            destinationView?.dataDict = self.previousViewDict
        }
        
    }
    
    //MARK:- didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

//MARK:- UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension SelectVehicleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SelectMoveCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectMoveCollectionViewCell", for: indexPath) as! SelectMoveCollectionViewCell
        
        // Change Background colour.
        if indexPath.item == selectedValue {
            cell.background.backgroundColor = UIColor(red: 29/255, green: 182/255, blue: 140/255, alpha: 1)
        } else {
            cell.background.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1)
        }
        

        // Data dict.
        let data = collectionViewDataArray[indexPath.item]
        
        if let name = data.name {
            cell.title_label.text = name
        }
        
        if let iconName = data.icon {
            
            URLSession.shared.dataTask(with: URL(string: iconName)!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("error found!")
                    return
                }
                
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    cell.mainImage_imageView.image = image
                }
                
            }).resume()
            
        }
    
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding : CGFloat = 5.0
        let collectionViewSize = main_collectionView.frame.size.width - padding
        let collectionViewSizeHeight = main_collectionView.frame.size.height - (padding + 10)
        return CGSize(width: collectionViewSize/2, height: collectionViewSizeHeight/2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell: SelectMoveCollectionViewCell = collectionView.cellForItem(at: indexPath) as! SelectMoveCollectionViewCell
        selectedValue = indexPath.item
        
        let data = collectionViewDataArray[indexPath.item]
        dataDict["vehicleData"] = data as AnyObject
        
        size_label.text = "Max Size:- " + data.length! + "m(L) ✖️" + data.weight! + "m(W) ✖️" + data.height! + "m(H)"
        weight_label.text = "Max Weight:- " + data.weight! + " kg"
        
        UIView.animate(withDuration: 0.25) {
            self.bigImage_imageView.sd_setImage(with: URL(string: data.icon!), placeholderImage: #imageLiteral(resourceName: "VehicleDummyImage"))
            self.view.layoutIfNeeded()
        }
        
        cell.background.backgroundColor = UIColor(red: 29/255, green: 182/255, blue: 140/255, alpha: 1)
        self.main_collectionView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        
    }

//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        
//        if let cell = collectionView.cellForItem(at: indexPath) as? SelectMoveCollectionViewCell {
//            cell.background.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1)
//        }
//        
//    }
    
}
