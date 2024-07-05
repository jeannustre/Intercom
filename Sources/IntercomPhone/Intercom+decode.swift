//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import Foundation
import IntercomUtils

//public extension IntercomPhone {
//    
//    /// This relies on `appContext` containing specific data at specific keys :
//    /// - `context`: a type conforming to `IntercomContext`, encoded as `Data` and to be decoded using the internal `decoder`.
//    func decode(context: [String:Any]) throws -> T {
//        guard let data = context["context"] as? Data else {
//            print("????????? No context")
//            throw IntercomError.noContextInUserInfoDictionary
//        }
//        let decoded = try decoder.decode(T.self, from: data)
//        print("Decoded received context from watch: \(decoded)")
//        return decoded
//    }
//}
