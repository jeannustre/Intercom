//
//  IntercomPhone.swift
//
//
//  Created by Jean Sarda on 17/06/2024.
//

import IntercomUtils
import Foundation
import WatchConnectivity
import UIKit

public class IntercomPhone<T: IntercomContext>: NSObject, ObservableObject, WCSessionDelegate, Intercom {
        
    public var sessionActivated: Bool = false
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    
    public var session: WCSession
    
    private init(session: WCSession) {
        self.session = session
        super.init()
    }
    
    public override convenience init() {
        self.init(session: .default)
    }
    
    public func activate() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }
    
    public func updateComplicationsOnWatch() {
        guard session.activationState == .activated else {
            print("Tried to update complications on watch while session not active")
            return
        }
        print("Complication updates remaining: \(session.remainingComplicationUserInfoTransfers)")
        if session.isComplicationEnabled {
            session.transferCurrentComplicationUserInfo()
        }
    }
    
//    private func sendJWT(replyHandler: @escaping ([String : Any]) -> Void) {
//        let currentAuth = APIService.shared.authenticationAdapter.authorization
//        let result: [String:Any] = ["access": currentAuth?.accessToken as Any,
//                                    "refresh": currentAuth?.refreshToken as Any]
//        replyHandler(result)
//    }
    
    
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            self.sessionActivated = true
        }
        print("⌚️ Phone Comms : activation completed, status \(activationState.rawValue), error: \(error?.localizedDescription ?? "nil")")
//        try? send(context: PhoneAppContext(navigating: false))
//        _ = try? self.decode(context: session.receivedApplicationContext)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("WATCHPHONE: received message with replyHandler: \(message)")
        
        if let command = message["command"] as? String {
            switch command {
            case "getNavigating":
                if true {
                    print("Sending navigating")
                    // DispatchQueue.main.async { might be warranted here depending on what u do in this function.
                    replyHandler(["navigating": true])
                    // }
                } else {
                    print("Error finding or encoding control data")
                    replyHandler(["error": "Could not encode controlData on device, might be missing"])
                }
            default:
                print("Unhandled command: \(command)")
                break
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WATCHPHONE: received message: \(message)")
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        _ = try? decode(context: applicationContext)
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
