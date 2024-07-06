//
//  File.swift
//  
//
//  Created by Jean Sarda on 06/07/2024.
//

import WatchConnectivity

public class IntercomSession: NSObject, WCSessionDelegate {
    
    weak public var delegate: Delegate?
    public var session: WCSession = .default
    public var canSend: Bool = false
    public var canReceive: Bool = false
    public var reachable: Bool = false
    
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    
    public init(delegate: Delegate? = nil, session: WCSession) {
        self.delegate = delegate
        self.session = session
        super.init()
    }
    
    public func activate() {
        session.delegate = self
        session.activate()
    }
    
    //MARK: - WCSessionActivationState
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        switch activationState {
        case .activated:
            canSend = true
            canReceive = true
        case .inactive:
            canSend = false
            canReceive = true
        case .notActivated:
            canSend = false
            canReceive = false
        }
        reachable = session.isReachable
        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
        delegate?.session(didReceiveApplicationContext: session.receivedApplicationContext)
    }
    
    #if os(iOS)
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        canSend = false
        canReceive = true
        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        canSend = false
        canReceive = false
        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
    }
    
    #endif
    
    //MARK: - Receiving Messages
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        delegate?.session(didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        delegate?.session(didReceiveMessage: message)
    }
    
    //MARK: - Receiving Context
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        delegate?.session(didReceiveApplicationContext: applicationContext)
    }
    
    //MARK: - Reachability
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        delegate?.reachabilityChanged(reachable: session.isReachable)
    }
}

public extension IntercomSession {
    
    protocol Delegate: AnyObject {
        
        func activationStatusChanged(canSend: Bool, canReceive: Bool)
        func reachabilityChanged(reachable: Bool)
        func session(didReceiveMessage message: [String : Any])
        func session(didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void)
        func session(didReceiveApplicationContext applicationContext: [String : Any])
    }
    
}
