//
//  File.swift
//  
//
//  Created by Jean Sarda on 06/07/2024.
//

import Foundation

public extension Intercom {
    
    func decode<T:Decodable>(context: [String:Any]) throws -> T {
        guard let data = context[IntercomKey.context.rawValue] as? Data else {
            throw IntercomError.noContextInUserInfoDictionary
        }
        return try decoder.decode(T.self, from: data)
    }
}
