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
    
    public typealias CommandHandler = ([String:Any]?) -> [String:Any]
    
    @Published public var receivedContext: T?
    @Published public var reachable: Bool = false
    
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    public let session: WCSession = .default
    public var canSend: Bool = false
    public var canReceive: Bool = false
    public weak var delegate: IntercomDelegate?
    
    private var commandHandlers: [String:CommandHandler] = [:]

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
        case .requestContextUpdate:
            break //TODO: should gather and re-send context from here
        case .analytic(let event, let parameters):
            if let handler = commandHandlers[event] {
                return handler(parameters)
            }
        case .custom(let name, let parameters):
            if let handler = commandHandlers[name] {
                return handler(parameters)
            }
        }
        return [:]
    }
    
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
        @unknown default:
            canSend = true
            canReceive = true
        }
        reachable = session.isReachable
        delegate?.sessionActivated(isPaired: session.isPaired)
    }

    #if os(iOS)

    public func sessionDidBecomeInactive(_ session: WCSession) {
        canSend = false
        canReceive = true
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        canSend = false
        canReceive = false
    }

    #endif

    //MARK: - Receiving Messages

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let command = IntercomCommand(message: message) else {
            return
        }
        _ = perform(command: command)
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("IntercomPhone: didReceiveMessageData called, but not implemented")
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
