//
//  File.swift
//  
//
//  Created by Jean Sarda on 06/07/2024.
//

import Foundation

public extension Intercom {
    
    func decode<T:Decodable>(context: [String:Any]) throws -> T {
        guard session.activationState == .activated else { throw IntercomError.sessionNotActivated }
        guard let data = context["context"] as? Data else {
            throw IntercomError.noContextInUserInfoDictionary
        }
        return try decoder.decode(T.self, from: data)
    }
}
