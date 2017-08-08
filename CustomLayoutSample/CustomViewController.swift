//
//  CustomViewController.swift
//  CustomLayoutSample
//
//  Created by Sachin Hegde on 8/1/17.
//  Copyright © 2017 Sachin Hegde. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController , IConnect , IRegisterLocalCameraEventListener , IRegisterRemoteCameraEventListener, IRegisterRemoteMicrophoneEventListener, IRegisterLocalMicrophoneEventListener, IRegisterLocalSpeakerEventListener, IRegisterParticipantEventListener {

    // MARK: - Properties and variables
    
    @IBOutlet weak var remoteViews: UIView!
    @IBOutlet weak var selfView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    private var connector:Connector?
    private var remoteViewsMap:[String:UIView] = [:]
    private var numberOfRemoteViews = 0
    var resourceID          = ""
    var displayName         = ""
    var micMuted            = false
    var cameraMuted         = false
    var expandedSelfView    = false
    
    let VIDYO_TOKEN         = "cHJvdmlzaW9uAFNhY2hpbkBlOGQ5YTMudmlkeW8uaW8ANjM2Njk5Njg2NzEAADNkNDM1MGM1ZDg1Y2Q0YjRkZWUzNjQzYzJlYzJmZDJiOTdiNjgxNWE2Yjc4Y2RjZmMyNzdkNWY1ZWRmNDdiYWJkNTk4NDQ0NDUxOTBlMzgyMjY2NmRmNGRhMTc1MWFmMA==" // Get a valid token. It is recommended that you create short lived tokens on your applications server and then pass it down here. For details on how to get a token check out - https://developer.vidyo.io/documentation/4-1-15-7/getting-started#Tokens 
    
    // MARK: - Viewcontroller override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        selfView.frame.size.width   = UIScreen.main.bounds.size.width / 4
        selfView.frame.size.height  = UIScreen.main.bounds.size.height / 4
        
        selfView.layer.borderColor  = UIColor.black.cgColor
        selfView.layer.borderWidth  = 1.0
        
        // Setting tap gesture on the self view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(CustomViewController.toggleSelfView))
        selfView.addGestureRecognizer(tap)
        
        // Create VidyoIO connector object
        connector = Connector(nil,                                      // For custom handling of views, set this to nil
                              viewStyle: .CONNECTORVIEWSTYLE_Default,   // Passing default,
                              remoteParticipants: 4,                    // In this sample I am only showing maximum of 4 participants at a time
                              logFileFilter: UnsafePointer("info@VidyoClient info@VidyoConnector warning"),
                              logFileName: UnsafePointer(""),
                              userData: 0)
        
        if connector != nil {
            // When For custom view we need to register to all the device events
            connector?.registerLocalCameraEventListener(self)
            connector?.registerRemoteCameraEventListener(self)
            connector?.registerLocalSpeakerEventListener(self)
            connector?.registerLocalMicrophoneEventListener(self)
            connector?.registerParticipantEventListener(self)
        }
        
        // register for rotation events
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CustomViewController.rotated),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshUI()
        connector?.connect(UnsafePointer("prod.vidyo.io"),
                           token: UnsafePointer("cHJvdmlzaW9uAFNhY2hpbkBlOGQ5YTMudmlkeW8uaW8ANjM2Njk5Njg2NzEAADNkNDM1MGM1ZDg1Y2Q0YjRkZWUzNjQzYzJlYzJmZDJiOTdiNjgxNWE2Yjc4Y2RjZmMyNzdkNWY1ZWRmNDdiYWJkNTk4NDQ0NDUxOTBlMzgyMjY2NmRmNGRhMTc1MWFmMA=="),
                           displayName: UnsafePointer(displayName),
                           resourceId: UnsafePointer(resourceID),
                           connect: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Class methods

    
    func rotated() {
        self.refreshUI()
    }
    
    func toggleSelfView() {
        self.expandedSelfView = !self.expandedSelfView
        
        UIView.animate(withDuration: 0.5, animations: {
            if self.expandedSelfView {
                self.selfView.frame.size.width  = UIScreen.main.bounds.size.width / 2
                self.selfView.frame.size.height = UIScreen.main.bounds.size.height / 2
            } else {
                self.selfView.frame.size.width  = UIScreen.main.bounds.size.width / 4
                self.selfView.frame.size.height = UIScreen.main.bounds.size.height / 4
            }
            self.selfView.frame.origin.x = UIScreen.main.bounds.size.width - self.selfView.frame.size.width - 10
            self.selfView.frame.origin.y = UIScreen.main.bounds.size.height - self.selfView.frame.size.height - 60
            self.connector?.showView(at: UnsafeMutableRawPointer(&self.selfView),
                                     x: 0,
                                     y: 0,
                                     width: UInt32(self.selfView.frame.size.width),
                                     height: UInt32(self.selfView.frame.size.height))
        }, completion:nil)
        
    }
    
    func refreshUI() {
        DispatchQueue.main.async {
            
            // Updating local (self) view
            if self.expandedSelfView {
                self.selfView.frame.size.width  = UIScreen.main.bounds.size.width / 2
                self.selfView.frame.size.height = UIScreen.main.bounds.size.height / 2
            } else {
                self.selfView.frame.size.width  = UIScreen.main.bounds.size.width / 4
                self.selfView.frame.size.height = UIScreen.main.bounds.size.height / 4
            }
            self.selfView.frame.origin.x = UIScreen.main.bounds.size.width - self.selfView.frame.size.width - 10
            self.selfView.frame.origin.y = UIScreen.main.bounds.size.height - self.selfView.frame.size.height - 60
            
            self.connector?.showView(at: UnsafeMutableRawPointer(&self.selfView),
                                     x: 0,
                                     y: 0,
                                     width: UInt32(self.selfView.frame.size.width),
                                     height: UInt32(self.selfView.frame.size.height))
            
            
            // Updating remote views
            let refFrames   = RemoteViewLayout.getTileFrames(numberOfTiles: self.numberOfRemoteViews)
            var index       = 0
            for var remoteView in self.remoteViewsMap.values {
                let refFrame        = refFrames[index] as! CGRect
                remoteView.frame    = refFrame
                self.connector?.showView(at: UnsafeMutableRawPointer(&remoteView),
                                         x: 0,
                                         y: 0,
                                         width: UInt32(refFrame.size.width),
                                         height: UInt32(refFrame.size.height))
                index += 1
                
                // updating label location
                for subview in remoteView.subviews
                {
                    if let item = subview as? UILabel
                    {
                        item.frame = CGRect(x: 0,
                                            y: 10,
                                            width: remoteView.frame.width,
                                            height: 20)
                    }
                }
            }
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
    
    // MARK: - IRegisterParticipantEventListener delegate methods
    
    func onParticipantLeft(_ participant: Participant!) {
        
    }
    
    func onParticipantJoined(_ participant: Participant!) {
        
    }
    
    func onLoudestParticipantChanged(_ participant: Participant!, audioOnly: Bool) {
        
    }
    
    func onDynamicParticipantChanged(_ participants: NSMutableArray!, remoteCameras: NSMutableArray!) {
        print("onDynamicParticipantChanged Participants - \(participants.count) cameras - \(remoteCameras.count)")
        
        for item in participants {
            let remoteParticipant = item as! Participant
            print("Participant Name - \(remoteParticipant.getName())")
        }
        
        
        for item in remoteCameras {
            let remoteCamera = item as! RemoteCamera
            print("Participant Name - \(remoteCamera.getName())")
        }
        
    }
    
    // MARK: - IRegisterLocalSpeakerEventListener delegate methods
    
    func onLocalSpeakerAdded(_ localSpeaker: LocalSpeaker!) {
        
    }
    
    func onLocalSpeakerRemoved(_ localSpeaker: LocalSpeaker!) {
        
    }
    
    func onLocalSpeakerSelected(_ localSpeaker: LocalSpeaker!) {
        
    }
    
    func onLocalSpeakerStateUpdated(_ localSpeaker: LocalSpeaker!, state: DeviceState) {
        
    }
    
    // MARK: - IRegisterLocalMicrophoneEventListener delegate methods
    
    func onLocalMicrophoneAdded(_ localMicrophone: LocalMicrophone!) {
        
    }
    
    func onLocalMicrophoneRemoved(_ localMicrophone: LocalMicrophone!) {
        
    }
    
    func onLocalMicrophoneSelected(_ localMicrophone: LocalMicrophone!) {
        
    }
    
    func onLocalMicrophoneStateUpdated(_ localMicrophone: LocalMicrophone!, state: DeviceState) {
        
    }
    
    // MARK: - IRegisterRemoteMicrophoneEventListener delegate methods

    func onRemoteMicrophoneAdded(_ remoteMicrophone: RemoteMicrophone!, participant: Participant!) {
        
    }
    
    func onRemoteMicrophoneRemoved(_ remoteMicrophone: RemoteMicrophone!, participant: Participant!) {
        
    }
    
    func onRemoteMicrophoneStateUpdated(_ remoteMicrophone: RemoteMicrophone!, participant: Participant!, state: DeviceState) {
        
    }
    
    // MARK: - IRegisterLocalCameraEventListener delegate methods
    
    func onLocalCameraRemoved(_ localCamera: LocalCamera!) {
        self.selfView.isHidden = true
    }
    
    func onLocalCameraAdded(_ localCamera: LocalCamera!) {
        if ((localCamera) != nil) {
            self.selfView.isHidden = false
            DispatchQueue.main.async {
                self.connector?.assignView(toLocalCamera: UnsafeMutableRawPointer(&self.selfView),
                                           localCamera: localCamera,
                                           displayCropped: true,
                                           allowZoom: false)
                self.connector?.showViewLabel(UnsafeMutableRawPointer(&self.selfView),
                                              showLabel: false)
                self.connector?.showView(at: UnsafeMutableRawPointer(&self.selfView),
                                         x: 0,
                                         y: 0,
                                         width: UInt32(self.selfView.bounds.size.width),
                                         height: UInt32(self.selfView.bounds.size.height))
            }
        }
    }
    
    func onLocalCameraSelected(_ localCamera: LocalCamera!) {
        
    }
    
    func onLocalCameraStateUpdated(_ localCamera: LocalCamera!, state: DeviceState) {
        
    }
    
    // MARK: - IRegisterRemoteCameraEventListener delegate methods
    
    func onRemoteCameraAdded(_ remoteCamera: RemoteCamera!, participant: Participant!) {
        numberOfRemoteViews += 1
        DispatchQueue.main.async {
            var newRemoteView = UIView()
            newRemoteView.layer.borderColor = UIColor.black.cgColor
            newRemoteView.layer.borderWidth = 1.0
            self.remoteViews.addSubview(newRemoteView)
            self.remoteViewsMap[participant.getId()] = newRemoteView
            self.connector?.assignView(toRemoteCamera: UnsafeMutableRawPointer(&newRemoteView),
                                       remoteCamera: remoteCamera,
                                       displayCropped: true,
                                       allowZoom: true)
            self.connector?.showViewLabel(UnsafeMutableRawPointer(&newRemoteView),
                                          showLabel: false)
            
            // Adding custom UILabel to show the participant name
            let newParticipantNameLabel = UILabel()
            newParticipantNameLabel.text = participant.getName()
            newParticipantNameLabel.textColor = UIColor.white
            newParticipantNameLabel.textAlignment = .center
            newParticipantNameLabel.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            newParticipantNameLabel.shadowOffset = CGSize(width: 1, height: 1)
            newParticipantNameLabel.font = newParticipantNameLabel.font.withSize(14)
            newRemoteView.addSubview(newParticipantNameLabel)
            
            self.refreshUI()
        }
    }
    
    func onRemoteCameraRemoved(_ remoteCamera: RemoteCamera!, participant: Participant!) {
        numberOfRemoteViews -= 1
        DispatchQueue.main.async {
            let remoteView = self.remoteViewsMap.removeValue(forKey: participant.getId())
            for view in (remoteView?.subviews)!{
                view.removeFromSuperview()
            }
            remoteView?.removeFromSuperview()
        
            self.refreshUI()
        }
    }
    
    func onRemoteCameraStateUpdated(_ remoteCamera: RemoteCamera!, participant: Participant!, state: DeviceState) {
        
    }

    // MARK: - Actions
    
    @IBAction func cameraClicked(_ sender: Any) {
        if cameraMuted {
            cameraMuted = !cameraMuted
            self.cameraButton.setImage(UIImage(named: "cameraOn.png"), for: .normal)
            connector?.setCameraPrivacy(cameraMuted)
            self.selfView.isHidden = cameraMuted
        } else {
            cameraMuted = !cameraMuted
            self.cameraButton.setImage(UIImage(named: "cameraOff.png"), for: .normal)
            connector?.setCameraPrivacy(cameraMuted)
            self.selfView.isHidden = cameraMuted
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
