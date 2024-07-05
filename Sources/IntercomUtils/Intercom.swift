//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import WatchConnectivity

public protocol Intercom {
    var session: WCSession { get set }
    var encoder: JSONEncoder { get set }
    var decoder: JSONDecoder { get set }
}

