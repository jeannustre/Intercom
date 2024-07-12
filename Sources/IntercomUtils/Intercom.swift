//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import WatchConnectivity

public protocol Intercom {
    var encoder: JSONEncoder { get set }
    var decoder: JSONDecoder { get set }
    var session: WCSession { get }
    
    func perform(command: IntercomCommand) -> [String:Any]?
    func send<T:Encodable>(context: T) throws
    func send(command: IntercomCommand, replyHandler: (([String:Any])->Void)?, errorHandler: ((Error)->Void)?) throws
}
