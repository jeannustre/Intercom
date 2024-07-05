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
        let contextData = try encoder.encode(context)
        try session.updateApplicationContext(["context":contextData])
    }
}
