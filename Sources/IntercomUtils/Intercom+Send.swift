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
        session.sendMessageData(encoded,
                                replyHandler: replyHandler,
                                errorHandler: errorHandler)
    }
    
    func send(command: IntercomCommand, replyHandler: (([String:Any])->Void)? = nil, errorHandler: ((any Error)->Void)? = nil) throws {
        guard session.activationState == .activated else {
            throw IntercomError.sessionNotActivated
        }
        
        var message: [String:Any] = [
            IntercomKey.command.rawValue: command.name()
        ]
        if let parameters = command.parameters(),
           let encodedParameters = try? JSONEncoder().encode(parameters) {
            message[IntercomKey.parameters.rawValue] = encodedParameters
        }
        
        session.sendMessage(
            message,
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
    }
}
