//
//  CalenderViewController.swift
//  MoversProvider
//
//  Created by osvinuser on 15/12/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import FSCalendar
import AVFoundation
import SwiftyJSON

class CalenderViewController: UIViewController , FSCalendarDelegate, FSCalendarDataSource{
    
    //MARK:- Variables
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var noInternetViewObj = NoInternetConnectionView()
    var serverErrorViewObj = ServerErrorView()
    var scheduleDataList = [JSON]()
    var selectedDateData = [Dictionary<String, Any>]()
    private let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    //MARK:-IBOutlets
    @IBOutlet weak var tableViewListing: UITableView!
    @IBOutlet var viewNoDataAvailable: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    var selecteddate = Date()
    var selectedDateCalender = NSString()
    
    //MARK:- App life cycle
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.navigationBarSetUp()
        self.selecteddate = NSDate() as Date
        let dateNow :Date = self.selecteddate as Date
        selectedDateCalender = dateNow.stringFromDateMethod(format: .dateNow) as NSString
        calendar.select(self.dateFormatter.date(from: selectedDateCalender as String))
        getAllTheCurrentDateData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
   
    // MARK:- FSCalendarDataSource
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.dateFormatter.date(from: "2040-10-30")!
    }
    
    // MARK:- FSCalendarDelegate
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        selecteddate = (calendar.currentPage as NSDate) as Date
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if date != NSDate() as Date{
            return UIColor.clear
        }
        return UIColor.init(red: 29/255, green: 182/255, blue: 140/255, alpha: 1)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //For chnging the string date to check for that day events
        selectedDateData.removeAll()
        self.selecteddate = date
        let dateNow :Date = self.selecteddate as Date
        selectedDateCalender = dateNow.UtctoLocal(date: dateNow) as NSString
        getAllTheCurrentDateData()
      //  self.managedDateWiseData()
    }
    
    func strLableNameData(string: String)-> NSMutableAttributedString{
        var myMutableString = NSMutableAttributedString()
        let arr = string.components(separatedBy: "-")
        myMutableString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName:UIFont(name: "Raleway-SemiBold", size: 12.0)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 29/255, green: 182/255, blue: 140/255, alpha: 1), range: NSRange(location:arr[0].count + 1,length:arr[1].count))
        return myMutableString
    }
    
    //MARK: - IBActions
    @IBAction func navigationBack_buttonAction(_ sender: Any) {
        self.navigationBackAndCancelButtonAction()
    }
    @IBAction func btnActionNextMonth(_ sender: Any) {
        let nextmonth = self.gregorian.date(byAdding: .month, value: 1, to: selecteddate as Date)!
        self.calendar.setCurrentPage(nextmonth, animated: true)
    }
    @IBAction func btnActionPreviousMonth(_ sender: Any) {
        let pastmonth = self.gregorian.date(byAdding: .month, value: -1, to: selecteddate as Date)!
        self.calendar.setCurrentPage(pastmonth, animated: true)
    }
}
extension CalenderViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDateData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UpcomingScheduleTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "UpcomingScheduleTableViewCell", for: indexPath) as? UpcomingScheduleTableViewCell
        cell?.selectionStyle = .none
        cell?.backgroundView?.sizeToFit()
        if indexPath.row != 0{
            cell?.imageViewSeprator.image = #imageLiteral(resourceName: "ic_calendar_list_long")
        }
        else{
            cell?.imageViewSeprator.image = #imageLiteral(resourceName: "ic_calendar_list")
        }
        if let fName = selectedDateData[indexPath.row]["fname"] as? String{
            if let lastName = selectedDateData[indexPath.row]["lname"] as? String{
                let fullName = fName + " " + lastName
                if let title = selectedDateData[indexPath.row]["title"] as? String {
                    cell?.labelName.attributedText = strLableNameData(string: fullName + " - " + title )
                }
            }
        }
        if let startDate = selectedDateData[indexPath.row]["slot_starttime"] as? String{
            if let endDate = selectedDateData[indexPath.row]["slot_endtime"] as? String{
                let endDateUTC = UTCToLocal(format: .time, date: endDate, convertFormat: .timeAMPM)
                let arrendate = endDateUTC.components(separatedBy: " ")
                let startDateUTC = UTCToLocal(format: .time, date: startDate, convertFormat: .timeAMPM)
                let arrstartdate = startDateUTC.components(separatedBy: " ")
                cell?.labelTime.text = arrstartdate[0] + " - " + arrendate[0]
                cell?.labelAmPm.text  = arrendate[1]
            }
        }
        if let pickupLocation = selectedDateData[indexPath.row]["pickup_loc"] as? String{
            cell?.labelPickUpAddress.text = pickupLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let dropoffLoation = selectedDateData[indexPath.row]["destination_loc"] as? String{
            cell?.labelDropOff.text = dropoffLoation.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let homeObj = self.storyboard?.instantiateViewController(withIdentifier: "MoveDetailsViewController") as! MoveDetailsViewController
        let data = selectedDateData[indexPath.row]
        homeObj.moveId = data["id"] as? String
        homeObj.dataPass = ["stringToCheck" : "active"]
        self.navigationController?.pushViewController(homeObj, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
