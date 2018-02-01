//
//  MoveDetailsViewController.swift
//  MoversProvider
//
//  Created by osvinuser on 15/09/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import SwiftyJSON

class MoveDetailsViewController: UIViewController {
    
    //MARK:- IBOutlet
    @IBOutlet var mapImage_imageView: UIImageView!
    @IBOutlet var cancelMove_button: UIButton!
    @IBOutlet var callCustomer_button: UIButton!
    //@IBOutlet var vehicleName_label: UILabel!
    @IBOutlet var driverName_label: UILabel!
    @IBOutlet var driverImage_imageView: ImageViewDesign!
    @IBOutlet var itemDetails_button: ButtonDesign!
    @IBOutlet var dateTime_label: UILabel!
    @IBOutlet var price_label: UILabel!
    @IBOutlet var moveId_label: UILabel!
    @IBOutlet var dropoffLocation_label: UILabel!
    @IBOutlet var pickupLocation_label: UILabel!
    @IBOutlet var viewFareDetail_button: UIButton!
    @IBOutlet var viewFareDetail_view: UIView!
    @IBOutlet var callAndCancelButton_view: UIView!
    @IBOutlet var reciept_collectionView: UICollectionView!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet var move_collectionView: UICollectionView!
    @IBOutlet var customerImage_imageView: ImageViewDesign!
    @IBOutlet var customerName_label: UILabel!
    @IBOutlet var reciptNumber_label: UILabel!
    @IBOutlet var moveType_label: UILabel!
    @IBOutlet var vehicleName_label: UILabel!
    @IBOutlet weak var viewAcceptAndDecline: UIView!
    @IBOutlet weak var constraintsHeightFareDetails: NSLayoutConstraint!
    @IBOutlet weak var buttonOutletDescription: ButtonDesign!
    
    //MARK:- Variables
    var collectionViewImageArray = [#imageLiteral(resourceName: "TimeWhite"),#imageLiteral(resourceName: "DistanceWhite"),#imageLiteral(resourceName: "MoversSingle"), #imageLiteral(resourceName: "ic_loading_truck"),#imageLiteral(resourceName: "ic_loading_truck")]
    var collectionViewTitleArray = [String]()
    var reciptCollectionViewImageArray = [String]()
    var reciptCollectionViewTitleArray = [String]()
    var bookingData = [String : JSON]()
    var moveId : String!
    var userDetailData = [String : JSON]()
    var completeDict = [String: JSON]()
    var dataPass = [String : String]()
    var cancelInfoViewObj = CancelMoveView()
    var NoItemAvailable = NoItemAvailble()
    var viewBackGround = UIView()
    var showImageViewOnTapObj: ShowImageOnTapView?
    var priceEstimateViewObj = PriceEstimateView()

    //MARK:- App life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationBarSetUp()
        self.cancelMove_button.isEnabled = false
        self.callCustomer_button.isEnabled = false
        self.itemDetails_button.isEnabled = false
//        self.showDataOnView()
        price_label.text = dataPass["price"]
        dateTime_label.text = dataPass["date"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMoveDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Custom Methods
    // MARK:- showImageShowingView
    func showImageShowingView(indexItem: Int) {
        showImageViewOnTapObj = ShowImageOnTapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        showImageViewOnTapObj?.delegate = self
        showImageViewOnTapObj?.titleDescription_label.text = reciptCollectionViewTitleArray[indexItem]
        showImageViewOnTapObj?.itemImage_imageView.sd_setImage(with: URL(string: reciptCollectionViewImageArray[indexItem]), placeholderImage: UIImage(named: "DummyPhoto"))
        if indexItem == 0 {
            showImageViewOnTapObj?.title_label.text = "Reciept Number"
            
        } else if indexItem == 1 {
            showImageViewOnTapObj?.title_label.text = "Move"
            
        } else {
            showImageViewOnTapObj?.title_label.text = "Vehicle"
            
        }
        SharedInstance.appDelegate?.window!.addSubview(self.showImageViewOnTapObj!)
    }
    
    //showDataOnView
    func showDataOnView() {
        if dataPass["stringToCheck"] == "active" {
            self.viewFareDetail_view.isHidden = true
            self.callAndCancelButton_view.isHidden = false
            if self.bookingData["is_started"]?.string == "1" {
                self.cancelMove_button.setTitle("Message", for: .normal)
                self.cancelMove_button.setImage(#imageLiteral(resourceName: "MessageDriver"), for: .normal)
                buttonOutletDescription.setTitle("Active", for: .normal)
            } else {
                buttonOutletDescription.setTitle("Assigned", for: .normal)
                self.cancelMove_button.setTitle("Cancel", for: .normal)
                self.cancelMove_button.setImage(#imageLiteral(resourceName: "CancelMover"), for: .normal)
            }}
        else if dataPass["stringToCheck"] == "completed" {
            self.viewFareDetail_view.isHidden = false
            self.viewFareDetail_button.isHidden = false
            self.callAndCancelButton_view.isHidden = true
            buttonOutletDescription.setTitle("Completed", for: .normal)
        }
        else if dataPass["stringToCheck"] == "cancel" {
            self.viewFareDetail_view.isHidden = true
            self.callAndCancelButton_view.isHidden = true
            constraintsHeightFareDetails.constant = 0
            buttonOutletDescription.setTitle("Cancelled", for: .normal)
        }
        self.cancelMove_button.isEnabled = true
        self.callCustomer_button.isEnabled = true
        self.itemDetails_button.isEnabled = true
    }
    
    //MARK:- Button Actions
    @IBAction func viewFareDetail_buttonAction(_ sender: Any) {
        let viewObj = self.storyboard?.instantiateViewController(withIdentifier: "FareDetailViewController") as! FareDetailViewController
        viewObj.completeDict = completeDict
        viewObj.dataPass = self.dataPass
        self.navigationController?.pushViewController(viewObj, animated: true)
    }
    
    @IBAction func callCustomer_buttonAction(_ sender: UIButton) {
        let viewObj = self.storyboard?.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        self.navigationController?.pushViewController(viewObj, animated: true)
    }
    
    @IBAction func cancelMove_buttonAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Cancel" {
            self.viewBackGround = UIView.init(frame:CGRect( x:0 , y: 0 ,width: self.view.frame.size.width,height: self.view.frame.height))
            self.viewBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.navigationController?.view.addSubview(self.viewBackGround)
            self.cancelInfoViewObj = CancelMoveView(frame:CGRect(x: 30, y: self.view.center.y, width: self.view.frame.size.width - 30, height: 300 ))
            self.cancelInfoViewObj.center = self.view.center
            self.showViewPresentationAnimation(selfVc: self.view)
            self.cancelInfoViewObj.delegate = self
            self.viewBackGround.addSubview(self.cancelInfoViewObj)
        } else {
            let viewObj = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            viewObj.userDataDict = self.userDetailData
            viewObj.bookingDataDict = self.bookingData
            self.navigationController?.pushViewController(viewObj, animated: true)
        }
    }
    
    @IBAction func itemDetails_buttonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToItemDetail", sender: self)
    }
    
    @IBAction func navigationBack_buttonAction(_ sender: Any) {
        self.navigationBackAndCancelButtonAction()
    }
    @IBAction func btnActionConfirm(_ sender: Any) {
        //self.cancelMove()
    }
    
    //MARK:- StoryBoard Segue delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToItemDetail" {
            if let destination = segue.destination as? ItemDetailViewController {
                destination.bookingDataDict = bookingData
            }
        }
    }
    
    @IBAction func btnActionIfoPrice(_ sender: Any) {
        var maxPrice = 0.0
        var minPrice = 0.0
        self.priceEstimateViewObj = PriceEstimateView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.priceEstimateViewObj.delegate = self
        if let pricingData = self.completeDict["pricing_data"]?[0].dictionary{
            self.priceEstimateViewObj.delegate = self
            if let distance = pricingData["distance"]?.doubleValue { // may come in double
                var apiDistance = Float()
                apiDistance = Float(distance)
                self.priceEstimateViewObj.distanceValue_label.text =  apiDistance.cleanValue + " Km"
                let price = (pricingData["vehicle_km_charge"]?.floatValue ?? 0.0) * apiDistance
                //price = round(price)
                maxPrice = Double(price)
                minPrice = Double(price)
                self.priceEstimateViewObj.totalDistanceCharges_label.text = "$" + price.cleanValue
            }
            var apiDuration = Float()
            if let duration = pricingData["time"]?.doubleValue {
                apiDuration = Float(duration / 60)
            }
            self.priceEstimateViewObj.timeValue_label.text = apiDuration.cleanValue
            self.priceEstimateViewObj.distanceChargesValue_label.text = "$" + (pricingData["vehicle_km_charge"]?.stringValue ?? "0") + "/Km"
            self.priceEstimateViewObj.timeValueCharges_label.text = "$" + (pricingData["vehicle_mover_time_charge"]?.string ?? "0") + "/min"
            self.priceEstimateViewObj.minMaxCharges_label.text = "$" + (pricingData["vehicle_mover_time_charge"]?.string ?? "0") + "/min"
            
            let price = (pricingData["vehicle_mover_time_charge"]?.floatValue ?? 0.0) * apiDuration
            self.priceEstimateViewObj.totalTimeCharges_label.text = "$" + price.cleanValue
            maxPrice = maxPrice + Double(price)
            minPrice = minPrice + Double(price)
            
            let minmPrice = (pricingData["vehicle_mover_time_charge"]?.floatValue ?? 0.0) * (pricingData["min_time"]?.floatValue ?? 0.0)
            self.priceEstimateViewObj.minLoadUnloadValue_label.text = "$" + minmPrice.cleanValue
            minPrice = minPrice + Double(minmPrice)
           
            let maxmPrice = (pricingData["vehicle_mover_time_charge"]?.floatValue ?? 0.0)  * (pricingData["max_time"]?.floatValue ?? 0.0)
            self.priceEstimateViewObj.maxLoadUnloadValue_label.text = "$" + maxmPrice.cleanValue
            maxPrice = maxPrice + Double(maxmPrice)
            self.priceEstimateViewObj.minmaxValue_label.text = (pricingData["min_time"]?.stringValue  ?? "0") + " mins | " + (pricingData["max_time"]?.stringValue  ?? "0") + " mins"
            if let setting = self.completeDict["settingdata"]?[0].dictionary{
                self.priceEstimateViewObj.info1_label.text = "* " + (setting["gst_percentage"]?.string ?? "0") + "% GST will be included in final fare."
                self.priceEstimateViewObj.info2_label.text = "* The minimum fare for a booking is $" + (pricingData["vehicle_min_fare"]?.string ?? "0") + "."
            }
            self.priceEstimateViewObj.totalMInimumPrice_label.text = "$" + Float(minPrice).cleanValue
            self.priceEstimateViewObj.totalMaxPrice_Label.text = "$" + Float(maxPrice).cleanValue
            SharedInstance.appDelegate?.window!.addSubview(self.priceEstimateViewObj)
        }
    }
}

//MARK:- UICollectionViewDelegate,UICollectionViewDataSource
extension MoveDetailsViewController: UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == reciept_collectionView ? reciptCollectionViewTitleArray.count : collectionViewTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoveDetailsCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "MoveDetailsCollectionViewCell", for: indexPath) as? MoveDetailsCollectionViewCell
        
        if collectionView == reciept_collectionView {
            cell?.data_imageView.sd_setImage(with: URL(string: reciptCollectionViewImageArray[indexPath.item]), placeholderImage: UIImage(named: "DummyPhoto"))
            cell?.data_label.text = reciptCollectionViewTitleArray[indexPath.item]
            
        } else {
            cell?.data_imageView.image = collectionViewImageArray[indexPath.item]
            cell?.data_label.text = collectionViewTitleArray[indexPath.item]
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding : CGFloat = 5.0
        if collectionView == move_collectionView {
            let collectionViewSize = move_collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/5, height: collectionViewSize/5)
        } else {
            let collectionViewSize = reciept_collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == reciept_collectionView {
            self.showImageShowingView(indexItem: indexPath.item)
        }
    }
}

extension MoveDetailsViewController:cancelInformationViewDelegate{
    func delegateChecked() {
        self.showAlertLabel(error:"Check the Agreement First", position: self.view.frame.size.height -  120)
    }
    
    func descriptionDelegate() {
        self.showAlertLabel(error:"Please enter Move cancellation reason!", position: self.view.frame.size.height -  120)
    }
    
    func cancelButton() {
        self.viewBackGround.removeFromSuperview()
        self.cancelInfoViewObj.removeFromSuperview()
    }
    
    func cancelInformationViewDelegateCrossButtonFunction(strReason: String) {
        self.cancelMove(reason : strReason)
    }
}
//MARK:- ShowImageOnTapViewDelegate
extension MoveDetailsViewController: ShowImageOnTapViewDelegate {
    
    func ShowImageOnTapViewDelegateCrossButtonFunction(){
        self.showImageViewOnTapObj?.removeFromSuperview()
    }
}

//MARK:- PriceInformationViewDelegate
extension MoveDetailsViewController : PriceEstimateViewDelgate {
    func priceEstimateViewDelgateCrossAction() {
        self.priceEstimateViewObj.removeFromSuperview()
    }
}
