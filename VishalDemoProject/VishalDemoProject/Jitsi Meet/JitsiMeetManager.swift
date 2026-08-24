//
//  JitsiMeetManager.swift
//  PushKitDemo
//
//  Created by VISHAL VAGHASIYA on 07/09/22.
//

import Foundation
import CallKit
import JitsiMeetSDK
import AVFAudio
import UIKit
import AVFoundation

class JitsiMeetManager: NSObject {
    static let shared = JitsiMeetManager()
    
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var jitsiMeetView: JitsiMeetView?
    
    let callController = CXCallController()
    var presentingVc: UIViewController!
    var meetingID = String()
    var uuid: UUID?
    var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7InVzZXIiOnsiYXZhdGFyIjoiaHR0cHM6XC9cL3N0YWdnaW5nLmNhcmVjb29yZGluYXRpb25zLmNvbVwvdXBsb2FkXC9wcm9maWxlX3BpY1wvNGRjYmRjNWY0NDliODgzZGFlNjZlNzU1ZjA3YTkzOWNwcm9maWxlLmpwZWciLCJuYW1lIjoiYW5raXRhIG5leGlvcyBMTFAiLCJlbWFpbCI6ImFua2l0YUBuZXhpb3MuaW4iLCJpZCI6MjY1fSwiZ3JvdXAiOiIyZmUxMjdlZi02M2MwLTQ1YTMtYTgzZC1lOWRlYTg1ZDRlMmEtZGZlMzQwIn0sImF1ZCI6ImNhcmUiLCJpc3MiOiJjYXJlIiwic3ViIjoibWVldC5jYXJlY29vcmRpbmF0aW9ucy5jb20iLCJyb29tIjoiKiIsImV4cCI6MTcxNzc2MzQyNX0.WdPfvQ854xrjqu0Jr6RA7_OHfvwddNX-poBy2nphQ_I"
    var parentView: UIView = UIView()
    
    var joinedTime = String()
    override init() {
        super.init()
    }
    
    func startCall(handle: String) {
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: self.uuid!, handle: handle)
        startCallAction.isVideo = true
        
        let transaction = CXTransaction()
        transaction.addAction(startCallAction)
        
        requestTransaction(transaction)
    }
    
    func endCalll() {
        let endCallAction = CXEndCallAction(call: self.uuid ?? UUID())
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction \(action) successfully")
            }
        }
    }
    
    func startMeeting(){
        guard meetingID.count > 1 else { return }

        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            
            //Testing
            /*builder.serverURL = URL(string: "https://meet.jit.si")
            builder.room = "test123"*/
            
            builder.room = self.meetingID
            //builder.setSubject(self.callerName)
            builder.setSubject("Vishal Demo Project")
            
            //TODO: DEFAULT
            builder.setFeatureFlag("prejoinpage.enabled", withValue: false)
            builder.setFeatureFlag("pip.enabled", withBoolean: true)
            builder.setFeatureFlag("lobby-mode.enabled", withBoolean: true)
            builder.setFeatureFlag("toolbox.alwaysVisible", withValue: true)

            //TODO: MANAGE MORE OPTIONS
            builder.setFeatureFlag("car-mode.enabled",withBoolean: false)
            builder.setFeatureFlag("security-options.enabled",withBoolean: false)
            builder.setFeatureFlag("video-share.enabled",withBoolean: false)
            builder.setFeatureFlag("filmstrip.enabled",withBoolean: true) // FOR SELF VIEW CAMERA
            builder.setFeatureFlag("tile-view.enabled",withBoolean: false)
            builder.setFeatureFlag("settings.enabled", withBoolean: false)
            builder.setFeatureFlag("reactions.enabled", withBoolean: false)
            builder.setFeatureFlag("raise-hand.enabled",withBoolean: false)

            //TODO: MANAGE TABBAR BUTTON
            builder.setFeatureFlag("chat.enabled", withValue: false)
            
            //TODO: MANAGE HEADER
            builder.setFeatureFlag("add-people.enabled",withBoolean: false)
            builder.setFeatureFlag("invite.enabled",withBoolean: false)

            //TODO: OTHER
            builder.setFeatureFlag("speakerstats.enabled",withBoolean: false)
            builder.setFeatureFlag("live-streaming.enabled",withBoolean: false)
            builder.setFeatureFlag("participants-pane", withBoolean: false)
            builder.setFeatureFlag("participants-pane.enabled", withBoolean: false)
            builder.setFeatureFlag("overflow-menu.enabled", withValue: false)//MORE OPTIONS MENU

            //TODO: WHILE USING SCREEN SHARING
            builder.setFeatureFlag("pip-while-screen-sharing.enabled",withBoolean: false)
            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: false)
            builder.setFeatureFlag("android.screensharing.enabled", withBoolean: false)

            //TODO: WHILE SCREEN RECORDING
            builder.setFeatureFlag("ios.recording.enabled",withBoolean: false)
            
//            builder.token = self.token
            builder.userInfo = JitsiMeetUserInfo.init(displayName: "Vishal Vaghasiya", andEmail: "vishal@nexios.in", andAvatar: URL.init(string: "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250"))
            //builder.setAudioMuted(true)
            //builder.setVideoMuted(true)
        }
        
        self.jitsiMeetView?.join(options)
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        
        self.pipViewCoordinator = PiPViewCoordinator(withView: self.jitsiMeetView!)
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: self.parentView)
        self.pipViewCoordinator?.configureAsStickyView()
        self.pipViewCoordinator?.delegate = self
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: UIApplication.shared.keyWindow?.rootViewController?.view)
        
        // animate in
        self.jitsiMeetView?.alpha = 0
        self.pipViewCoordinator?.show()
    }
    
    func joinMeeting(){
        guard meetingID.count > 1 else { return }
        
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.room = self.meetingID
            //builder.setSubject(self.callerName)
            builder.setSubject("Vishal Demo Project")
            builder.token = self.token
            builder.userInfo = JitsiMeetUserInfo.init(displayName: "Vishal Vaghasiya Join", andEmail: "vishal@nexios.in", andAvatar: URL.init(string: "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250"))
            //builder.setAudioMuted(true)
            //builder.setVideoMuted(true)
        }
        
        self.jitsiMeetView?.join(options)
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        
        self.pipViewCoordinator = PiPViewCoordinator(withView: self.jitsiMeetView!)
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: self.parentView)
        self.pipViewCoordinator?.configureAsStickyView()
        self.pipViewCoordinator?.delegate = self
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: UIApplication.shared.keyWindow?.rootViewController?.view)
        
        // animate in
        self.jitsiMeetView?.alpha = 0
        self.pipViewCoordinator?.show()
    }

    //MARK: CALL USING MEET LINK
    func joinMeetingUsingLink(){
        guard meetingID.count > 1 else { return }
        
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.room = self.meetingID
            builder.setSubject("Care Coordinations")
            builder.token = self.token
            builder.userInfo = JitsiMeetUserInfo.init(displayName: "Vishal Vaghasiya Link", andEmail: "vishal@nexios.in", andAvatar: URL.init(string: "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250"))
        }
        
        self.jitsiMeetView?.join(options)
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        
        self.pipViewCoordinator = PiPViewCoordinator(withView: self.jitsiMeetView!)
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: self.parentView)
        self.pipViewCoordinator?.configureAsStickyView()
        self.pipViewCoordinator?.delegate = self
        //self.pipViewCoordinator?.configureAsStickyView(withParentView: UIApplication.shared.keyWindow?.rootViewController?.view)
        
        // animate in
        self.jitsiMeetView?.alpha = 0
        self.pipViewCoordinator?.show()
    }
    
    func endMeeting() {
        if(jitsiMeetView != nil) {
            self.pipViewCoordinator?.hide(completion: { success in
                if success {
                    self.endCalll()
                    self.jitsiMeetView?.leave()
                    self.pipViewCoordinator = nil
                    self.jitsiMeetView = nil
                    self.jitsiMeetView?.removeFromSuperview()
                    self.pipViewCoordinator = nil
                }
            })
            //jitsiMeetView?.hangUp()
        }
    }
    
    func joinedAndEndMeeting(){
        self.endMeeting()
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }
}

extension JitsiMeetManager: JitsiMeetViewDelegate {
    func ready(toClose data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.hide() { _ in
            if self.jitsiMeetView != nil {
                self.cleanUp()
            }
        }
    }
    
    func conferenceWillJoin(_ data: [AnyHashable : Any]!){
        print("conferenceWillJoin::")
    }
    
    func conferenceJoined(_ data: [AnyHashable : Any]!){
        print("conferenceJoined::")
    }
    
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        print("conferenceTerminated::")
    }
    
    func participantLeft(_ data: [AnyHashable : Any]!) {
        print("----- participantLeft -----")
    }
    
    func participantJoined(_ data: [AnyHashable : Any]!) {
        print("participantJoined::")
    }
}

extension JitsiMeetManager: PiPViewCoordinatorDelegate {
    func exitPictureInPicture() {
        print("exitPictureInPicture::")
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.enterPictureInPicture()
    }
}
