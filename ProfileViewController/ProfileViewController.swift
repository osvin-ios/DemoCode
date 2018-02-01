//
//  ProfileViewController.swift
//  MoversProvider
//
//  Created by osvinuser on 11/09/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import FloatRatingView

class ProfileViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet var ratingView: FloatRatingView!
    @IBOutlet var wallet_tableView: UITableView!
    @IBOutlet var walletBalance_label: LabelDesign!
    @IBOutlet var vehicleName_label: UILabel!
    @IBOutlet var driverName_label: UILabel!
    @IBOutlet var driverImage_imageView: ImageViewDesign!
    @IBOutlet var view_WalletBalance: UIView!
    @IBOutlet var changePassword_button: ButtonDesign!
    @IBOutlet var viewAlert: UIView!
    @IBOutlet weak var viewAlertBackGround1Mover: UIView!
    @IBOutlet weak var viewAlertBackGround2Movers: UIView!
    @IBOutlet weak var imageViewMoversChoice: UIImageView!
    @IBOutlet weak var labelMoverChoice: UILabel!
    
    //MARK:- Variables
    var noInternetViewObj = NoInternetConnectionView()
    var serverErrorViewObj = ServerErrorView()
    var tableTransactionData = [JSON]()
    var numberOfMovers = 1
    var viewBackGround = UIView()
    private let refreshControl = UIRefreshControl()
    
    //MARK:- App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //pull to Refresh
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            wallet_tableView.refreshControl = refreshControl
        } else {
            wallet_tableView.addSubview(refreshControl)
        }
        let attributedStringTitle = NSAttributedString(string: "", attributes: [
            NSFontAttributeName :  UIFont(name: "Raleway-Bold", size: 16)!, //your font here
            NSForegroundColorAttributeName : UIColor(red: 23/255, green: 163/255, blue: 124/255, alpha: 1)
            ])
        self.refreshControl.attributedTitle = attributedStringTitle
        self.refreshControl.tintColor = UIColor(red: 23/255, green: 163/255, blue: 124/255, alpha: 1)
        self.refreshControl.addTarget(self, action: #selector(profileData(_:)), for: .valueChanged)
        wallet_tableView!.addSubview(refreshControl)
        //refreshControl.addTarget(self, action: #selector(profileData(_:)), for: .valueChanged)
        self.getUserProfile()
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 16)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.ratingView.delegate = self
        self.ratingView.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.viewBackGround.removeFromSuperview()
        self.viewAlert.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Custom Methods
    
    @objc private func profileData(_ sender: Any) {
        self.getUserProfile()
        self.refreshControl.endRefreshing()
    }
    
    //MARK:- Button Actions
    @IBAction func btnActionChangeMovers(_ sender: Any) {
        DispatchQueue.main.async {
            self.showViewPresentationAnimation(selfVc: self.view)
            self.viewBackGround = UIView.init(frame:CGRect( x:0 , y: 0 ,width: self.view.frame.size.width,height: self.view.frame.height))
            self.viewBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.viewAlert.frame = CGRect(x: 30, y: self.viewAlert.center.y, width: self.view.frame.size.width - 30, height: self.viewAlert.frame.size.height + 20)
            self.viewAlert.center = self.view.center
            self.navigationController?.view.addSubview(self.viewBackGround)
            self.viewBackGround.addSubview(self.viewAlert)
        }
    }
    @IBAction func logout_buttonAction(_ sender: UIButton) {
        self.showAlertWithTwoButtons(title: "Movers", message: "Are you sure you want to Logout?", firstTitle: "YES", secondTitle: "NO") { (isSuccess) in
            if isSuccess.boolValue {
                self.logoutUser()
            }
        }
    }
    
    @IBAction func chnagePassword_buttonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "ChangePasswordViewController", sender: self)
    }
    
    @IBAction func btn_ActionSubmit(_ sender: Any) {
        self.setMovers()
    }
    
    @IBAction func btn_Action2Mover(_ sender: Any) {
        numberOfMovers = 2
        self.viewAlertBackGround1Mover.backgroundColor = UIColor.clear
        self.viewAlertBackGround2Movers.backgroundColor = UIColor.init(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1)
    }
    @IBAction func btn_Action1Mover(_ sender: Any) {
        numberOfMovers = 1
        self.viewAlertBackGround2Movers.backgroundColor = UIColor.clear
        viewAlertBackGround1Mover.backgroundColor = UIColor.init(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1)
    }
    @IBAction func btn_ActionAlertViewClose(_ sender: Any) {
        self.removeViewWithAnimation(selfVc: view)
        self.viewBackGround.removeFromSuperview()
        self.viewAlert.removeFromSuperview()
    }
}

//MARK:- UITableViewDelegate,UITableViewDataSource
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTransactionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WalletTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell", for: indexPath) as? WalletTableViewCell
        let data = self.tableTransactionData[indexPath.row]
        if let dateCreated = data["date_created"].string {
            cell?.date_label.text = "Date: " + UTCToLocal(format: .dateTimeAMPM,date: dateCreated, convertFormat: .dateTime)
        }
        let type = data["type"].string ?? ""
        if type == "3" {
            cell?.creditDebit_imageView.image = #imageLiteral(resourceName: "CreditLogo")
            cell?.amount_label.textColor = .black
            cell?.amount_label.backgroundColor = .white
            cell?.heading_label.text = "Amount added to your wallet."
            
            if let id = data["move_id"].string{
                cell?.tripId_label.text = "MoveID: " + id
            }
            
            if let amount = data["amount_credited"].string {
                cell?.amount_label.text = "+ $" + amount
            }
            
        } else {
            cell?.creditDebit_imageView.image = #imageLiteral(resourceName: "DebitLogo")
            cell?.amount_label.textColor = .white
            cell?.heading_label.text = "Amount transferred in your bank registered bank account."
            cell?.amount_label.backgroundColor = UIColor(red: 29/255, green: 182/255, blue: 140/255, alpha: 1)
            
            if let id = data["txn_id"].string{
                cell?.tripId_label.text = "TransID: " + id
            }
            
            if let amount = data["amount_debited"].string {
                cell?.amount_label.text = "- $" + amount
            }
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 160))
        subView.backgroundColor = .clear
        view_WalletBalance.frame = CGRect(x: 5, y: 0, width: wallet_tableView.frame.size.width - 10, height: 160)
        view_WalletBalance.layer.cornerRadius = 5
        subView.addSubview(view_WalletBalance)
        return subView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let subView = UIView()
        subView.backgroundColor = UIColor.clear
        return subView
    }
}

//MARK:- FloatRatingViewDelegate
extension ProfileViewController: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
}
