//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import Foundation

public extension Intercom {
    
    func send<T:Encodable>(context: T) throws {
        guard session.activationState == .activated else { throw IntercomError.sessionNotActivated }
        let encoded = try encoder.encode(context)
        try session.updateApplicationContext([IntercomKey.context.rawValue: encoded])
    }
    
    func send<T:Encodable>(message: T, replyHandler: ((Data)->Void)? = nil, errorHandler: ((Error)->Void)? = nil) throws {
        guard session.activationState == .activated else { throw IntercomError.sessionNotActivated }
        let encoded = try encoder.encode(message)
        try session.sendMessageData(encoded,
                                    replyHandler: replyHandler,
                                    errorHandler: errorHandler)
    }
    
    func send(command: IntercomCommand, replyHandler: (([String:Any])->Void)? = nil, errorHandler: ((any Error)->Void)? = nil) throws {
        guard session.activationState == .activated else {
            throw IntercomError.sessionNotActivated
        }
        do {
            try session.sendMessage(
                [
                    IntercomKey.command.rawValue: command.name()
                    //IntercomKey.parameters.rawValue: command.parameters()
                ],
                replyHandler: { response in
                    DispatchQueue.main.async {
                        replyHandler?(response)
                    }
                },
                errorHandler: { error in
                    DispatchQueue.main.async {
                        errorHandler?(error)
                    }
                }
            )
        } catch {
            print(error)
        }
        
    }
}
