//
//  File.swift
//  
//
//  Created by Jean Sarda on 06/07/2024.
//

import Foundation

//TODO: move to codable struct to gain associated types and command parameters
public enum IntercomCommand: String {
    case playSuccess = "command_play_success"
    
    case requestContextUpdate = "request_context_update"
    
    public init?(message: [String:Any]) {
        guard let value = message[IntercomKey.command.rawValue] as? String else { return nil }
        guard let command = IntercomCommand(rawValue: value) else { return nil }
        self = command
    }
}
