//
//  File.swift
//  
//
//  Created by Jean Sarda on 06/07/2024.
//

import Foundation

//TODO: move to codable struct to gain associated types and command parameters
//public enum IntercomCommand: String {
//    case playSuccess = "command_play_success"
//    
//    case requestContextUpdate = "request_context_update"
//    
//    public init?(message: [String:Any]) {

//    }
//}

public protocol Command {
    func name() -> String
    func parameters() -> [String:Any]
    init?(message: [String:Any])
}

public enum IntercomCommand: Command {
       
    case playSuccess
    case requestContextUpdate
    case custom(name: String, parameters: [String:Any])
    
    public init?(name: String, parameters: [String:Any]) {
        switch name {
        case "play_success":
            self = .playSuccess
        case "request_context_update":
            self = .requestContextUpdate
        default:
            self = .custom(name: name, parameters: parameters)
        }
    }
    
    public init?(message: [String:Any]) {
        guard let value = message[IntercomKey.command.rawValue] as? String else { return nil }
        let parameters = message[IntercomKey.parameters.rawValue] as? [String:Any] ?? [:]
        self.init(name: value, parameters: parameters)
    }
    
    public func name() -> String {
        switch self {
        case .playSuccess:
            return "play_success"
        case .requestContextUpdate:
            return "request_context_update"
        case .custom(let name, _):
            return name
        }
    }
    
    public func parameters() -> [String : Any] {
        switch self {
        case .custom(_, let parameters):
            return parameters
        default:
            return [:]
        }
    }
    
    
}
