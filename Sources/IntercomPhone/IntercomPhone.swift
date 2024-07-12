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
    
    @Published public var receivedContext: T?
    @Published public var reachable: Bool = false
    
    public var sessionActivated: Bool = false
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
//    public var session: IntercomSession = IntercomSession()
    public let session: WCSession = .default
    public var canSend: Bool = false
    public var canReceive: Bool = false
    
    public typealias CommandHandler = ([String:Any]?) -> [String:Any]
    
    var commandHandlers: [String:CommandHandler] = [:]
    
//    public init() {
        
//    }
    
    public func registerCommandHandler(name: String, handler: @escaping CommandHandler) {
        commandHandlers[name] = handler
    }
    
    public func removeCommandHandler(name: String) {
        commandHandlers.removeValue(forKey: name)
    }
    
    public func activate() {
        session.delegate = self
        session.activate()
    }
    
    public func perform(command: IntercomCommand) -> [String:Any]? {
        switch command {
        case .playSuccess:
            break
//            feedbackGenerator.notificationOccurred(.success)
        case .requestContextUpdate:
            break //TODO: should gather and re-send context from here
        case .custom(let name, let parameters):
            if let handler = commandHandlers[name] {
                return handler(parameters)
            }
        }
        return [:]
    }
    
//    public func send<E>(context: E) throws where E : Encodable {
//        try session.send(context: context)
//    }
//    
//    public func send(command: IntercomUtils.IntercomCommand, replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((any Error) -> Void)? = nil) throws {
//        try session.send(command: command, replyHandler: replyHandler, errorHandler: errorHandler)
//    }
//    
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
//        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
//        delegate?.session(didReceiveApplicationContext: session.receivedApplicationContext)
    }

    #if os(iOS)

    public func sessionDidBecomeInactive(_ session: WCSession) {
        canSend = false
        canReceive = true
//        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        canSend = false
        canReceive = false
//        delegate?.activationStatusChanged(canSend: canSend, canReceive: canReceive)
    }

    #endif

    //MARK: - Receiving Messages

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print()
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print()
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = IntercomCommand(message: message),
           let response = perform(command: command) {
            replyHandler(response)
        } else {
            replyHandler([:])
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print("Didreceive message data with reply handler")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            replyHandler(messageData)
        })
        
    }
    
//    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        print()
////        delegate?.session(didReceiveMessage: message, replyHandler: replyHandler)
//    }
//
//    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print()
////        delegate?.session(didReceiveMessage: message)
//    }

    //MARK: - Receiving Context

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        delegate?.session(didReceiveApplicationContext: applicationContext)
    }

    //MARK: - Reachability

    public func sessionReachabilityDidChange(_ session: WCSession) {
        print()
//        delegate?.reachabilityChanged(reachable: session.isReachable)
    }

}
