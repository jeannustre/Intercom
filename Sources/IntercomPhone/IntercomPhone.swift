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

public class IntercomPhone<T: IntercomContext>: ObservableObject, Intercom {
    
    @Published public var receivedContext: T?
    @Published public var reachable: Bool = false
    
    public var sessionActivated: Bool = false
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    public var session: IntercomSession = IntercomSession(session: .default)
    
    public  init() {
        
    }
    
    public func activate() {
        session.delegate = self
        session.activate()
    }
    
    public func perform(command: IntercomCommand) {
        switch command {
        case .playSuccess:
            break
//            feedbackGenerator.notificationOccurred(.success)
        case .requestContextUpdate:
            break //TODO: should gather and re-send context from here
        }
    }
    
    public func send<E>(context: E) throws where E : Encodable {
        try session.send(context: context)
    }
    
    public func send(command: IntercomUtils.IntercomCommand, replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((any Error) -> Void)? = nil) throws {
        try session.send(command: command, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
}

extension IntercomPhone: IntercomSession.Delegate {
    
    public func activationStatusChanged(canSend: Bool, canReceive: Bool) {
        
    }
    
    public func reachabilityChanged(reachable: Bool) {
        
    }
    
    public func session(didReceiveMessage message: [String : Any]) {
        if let command = IntercomCommand(message: message) {
            perform(command: command)
        }
    }
    
    public func session(didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = IntercomCommand(message: message) {
            perform(command: command)
            replyHandler([:])
        }
    }
    
    public func session(didReceiveApplicationContext applicationContext: [String : Any]) {
        
        DispatchQueue.main.async {
            self.receivedContext = try? self.decode(context: applicationContext)
        }
    }
    
}
