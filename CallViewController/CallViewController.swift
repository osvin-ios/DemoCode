//
//  CallViewController.swift
//  MoversProvider
//
//  Created by osvinuser on 25/09/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import AVFoundation

class CallViewController: UIViewController, TCDeviceDelegate, TCConnectionDelegate {

    //MARK:- IBOutlet
    @IBOutlet var customerName_label: UILabel!
    @IBOutlet var customerNumber_label: UILabel!
    @IBOutlet var callStatus_label: UILabel!
    @IBOutlet var customerImage_imageView: UIImageView!
    @IBOutlet var endCall_button: ButtonDesign!
    @IBOutlet var muteCall_button: ButtonDesign!
    @IBOutlet var speakerCall_button: ButtonDesign!
    var isSpeaker = false
    var isMuted = false
    var timerClock = Timer()
    //MARK:- Variables
    var device:TCDevice?
    var connection:TCConnection?
    var userdetailData  = [String : String]()
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.runTimer()
        self.getTwilioToken()
        callStatus_label.text = "Start connecting"
        self.customerName_label.text = userdetailData["name"]
    }
    
    //MARK:- didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- ButtonActions
    @IBAction func navigationBack_buttonAction(_ sender: Any) {
        if let connection = connection {
            connection.disconnect()
            self.navigationBackAndCancelButtonAction()
        }
    }
    
    @IBAction func endCall_buttonAction(_ sender: Any) {
        WebServiceClass.showLoader(view: (SharedInstance.appDelegate?.window!)!)
        if let connection = connection {
            connection.disconnect()
        }
    }
    
    @IBAction func muteCall_buttonAction(_ sender: Any) {
        if isMuted{
            isMuted = false
            muteCall_button.backgroundColor = UIColor.clear
            connection?.isMuted = false
        }
        else{
            isMuted = true
            muteCall_button.backgroundColor = UIColor(red: 23/255, green: 163/255, blue: 124/255, alpha: 1)
            connection?.isMuted = true
        }
        }
    
    @IBAction func speakerCall_buttonAction(_ sender: Any) {
        if isSpeaker{
            isSpeaker = false
            do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            } catch let err {
                print(err)
            }
            speakerCall_button.backgroundColor = UIColor.clear
        }
        else{
            do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch let err {
            print(err)
            }
            isSpeaker = true
            device?.outgoingSoundEnabled = false
            speakerCall_button.backgroundColor = UIColor(red: 23/255, green: 163/255, blue: 124/255, alpha: 1)

        }
    }
    
    //MARK: Initialization methods
    func initializeTwilioDevice(_ token:String) {
        device = TCDevice.init(capabilityToken: token, delegate: self)
       // self.dialButton.isEnabled = true
        if let device = device {
            connection = device.connect(["To": userdetailData["phoneNumber"] ?? "+919569433151"], delegate: self)
        }
    }
    
    //MARK: TCDeviceDelegate
    func deviceDidStartListening(forIncomingConnections device: TCDevice) {
        callStatus_label.text = "Started listening for incoming connections"
        
    }
    
    func device(_ device: TCDevice, didStopListeningForIncomingConnections error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func device(_ device: TCDevice, didReceiveIncomingConnection connection: TCConnection) {
        if let parameters = connection.parameters {
            let from = parameters["From"]
            let message = "Incoming call from \(from)"
            let alertController = UIAlertController(title: "Incoming Call", message: message, preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "Accept", style: .default, handler: { (action:UIAlertAction) in
                connection.delegate = self
                connection.accept()
                self.connection = connection
            })
            let declineAction = UIAlertAction(title: "Decline", style: .cancel, handler: { (action:UIAlertAction) in
                connection.reject()
            })
            alertController.addAction(acceptAction)
            alertController.addAction(declineAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func device(_ device: TCDevice, didReceivePresenceUpdate presenceEvent: TCPresenceEvent) {
        
    }
    
    func runTimer() {
        self.timerClock = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer(){
        UIView.animate(withDuration: 0.25, animations: {
            if self.callStatus_label.text!.count > 20{
                self.callStatus_label.text = "Start Connecting"
            }
            else{
                self.callStatus_label.text = self.callStatus_label.text! + " ."
            }
        })
    }
    
    //MARK: TCConnectionDelegate
    func connectionDidConnect(_ connection: TCConnection) {
        callStatus_label.text = "Connected"
        endCall_button.isEnabled = true
        timerClock.invalidate()
    }
    
    func connectionDidDisconnect(_ connection: TCConnection) {
        timerClock.invalidate()
        WebServiceClass.successLoader(view: (SharedInstance.appDelegate?.window!)!)
        callStatus_label.text = "Disconnected"
        endCall_button.isEnabled = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func connectionDidStartConnecting(_ connection: TCConnection) {
        callStatus_label.text = "Started connecting...."
    }
    
    func connection(_ connection: TCConnection, didFailWithError error: Error?) {
        if let error = error {
            timerClock.invalidate()
            self.navigationBackAndCancelButtonAction()
        }
    }
}
