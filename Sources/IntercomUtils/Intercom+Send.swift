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
    
    func send<T:Encodable>(message: T, replyHandler: @escaping (Data)->Void, errorHandler: @escaping (Error)->Void) throws {
        guard session.activationState == .activated else { throw IntercomError.sessionNotActivated }
        let encoded = try encoder.encode(message)
        try session.sendMessageData(encoded,
                                    replyHandler: replyHandler,
                                    errorHandler: errorHandler)
    }
}
