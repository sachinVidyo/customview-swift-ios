//
//  CompositedViewController.swift
//  CustomLayoutSample
//
//  Created by Sachin Hegde on 7/24/17.
//  Copyright © 2017 Sachin Hegde. All rights reserved.
//

import UIKit

class CompositedViewController : UIViewController, IConnect {

    // MARK: - Properties and variables

    @IBOutlet weak var vidyoView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    private var connector:Connector?
    var resourceID      = ""
    var displayName     = ""
    var micMuted        = false
    var cameraMuted     = false
    let VIDYO_TOKEN     = "cHJvdmlzaW9uAFNhY2hpbkBlOGQ5YTMudmlkeW8uaW8ANjM2Njk5Njg2NzEAADNkNDM1MGM1ZDg1Y2Q0YjRkZWUzNjQzYzJlYzJmZDJiOTdiNjgxNWE2Yjc4Y2RjZmMyNzdkNWY1ZWRmNDdiYWJkNTk4NDQ0NDUxOTBlMzgyMjY2NmRmNGRhMTc1MWFmMA==" // Get a valid token. It is recommended that you create short lived tokens on your applications server and then pass it down here. For details on how to get a token check out - https://developer.vidyo.io/documentation/4-1-15-7/getting-started#Tokens 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder :aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CompositedViewController.refreshUI), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        connector = Connector(UnsafeMutableRawPointer(&vidyoView),
                              viewStyle: .CONNECTORVIEWSTYLE_Default,
                              remoteParticipants: 4,
                              logFileFilter: UnsafePointer("info@VidyoClient info@VidyoConnector warning"),
                              logFileName: UnsafePointer(""),
                              userData: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshUI()
        connector?.connect(UnsafePointer("prod.vidyo.io"),
                                  token: UnsafePointer(VIDYO_TOKEN),
                                  displayName: UnsafePointer(displayName),
                                  resourceId: UnsafePointer(resourceID),
                                  connect: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshUI() {
        DispatchQueue.main.async {
            self.connector?.showView(at: UnsafeMutableRawPointer(&self.vidyoView),
                                     x: 0,
                                     y: 0,
                                     width: UInt32(self.vidyoView.frame.size.width),
                                     height: UInt32(self.vidyoView.frame.size.height))
        }
    }
    
    // MARK: - IConnect delegate methods

    func onSuccess() {
        print("Connection Successful")
    }
    
    func onFailure(_ reason: ConnectorFailReason) {
        print("Connection failed \(reason)")
    }
    
    func onDisconnected(_ reason: ConnectorDisconnectReason) {
        print("Call Disconnected")
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cameraClicked(_ sender: Any) {
        if cameraMuted {
            cameraMuted = !cameraMuted
            self.cameraButton.setImage(UIImage(named: "cameraOn.png"), for: .normal)
            connector?.setCameraPrivacy(cameraMuted)
        } else {
            cameraMuted = !cameraMuted
            self.cameraButton.setImage(UIImage(named: "cameraOff.png"), for: .normal)
            connector?.setCameraPrivacy(cameraMuted)
        }
    }

    @IBAction func micClicked(_ sender: Any) {
        if micMuted {
            micMuted = !micMuted
            self.micButton.setImage(UIImage(named: "microphoneOn.png"), for: .normal)
            connector?.setMicrophonePrivacy(micMuted)
        } else {
            micMuted = !micMuted
            self.micButton.setImage(UIImage(named: "microphoneOff.png"), for: .normal)
            connector?.setMicrophonePrivacy(micMuted)
        }
    }
    
    @IBAction func callClicked(_ sender: Any) {
        connector?.disconnect()
    }
    
    
}

