//
//  AddMoneyViewController.swift
//  Movers On Demand
//
//  Created by osvinuser on 04/09/17.
//  Copyright © 2017 Ios. All rights reserved.
//

import UIKit

class AddMoneyViewController: UIViewController {

    var tableData = ["$1000","$2000","$3000","$5000"]
    
    @IBOutlet var amount_textField: UITextField!
    @IBOutlet var amount_tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         self.navigationBarSetUp()
        amount_tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func navigationBack_buttonAction(_ sender: Any) {
        self.navigationBackAndCancelButtonAction()
        
    }

    @IBAction func navigationAdd_buttonAction(_ sender: Any) {
        DispatchQueue.main.async {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
            self.navigationController?.pushViewController(vc, animated: true)
           // self.performSegue(withIdentifier: "segueFromAddMoneyToPayment", sender: self)
        }
        
    }
  

}

extension AddMoneyViewController : UITableViewDataSource,UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddMoneyTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "AddMoneyTableViewCell", for: indexPath) as? AddMoneyTableViewCell
            cell?.amount_label.text = tableData[indexPath.row]
            cell?.selectionStyle = .none
            return cell!
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : AddMoneyTableViewCell? = tableView.cellForRow(at: indexPath) as? AddMoneyTableViewCell
        cell?.selection_imageView.image = #imageLiteral(resourceName: "SelectedCircle")
        amount_textField.text = cell?.amount_label.text
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell : AddMoneyTableViewCell? = tableView.cellForRow(at: indexPath) as? AddMoneyTableViewCell
        cell?.selection_imageView.image = #imageLiteral(resourceName: "EmptyCircle")
        //amount_textField.text = cell?.amount_label.text
    }
    
}
