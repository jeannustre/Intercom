//
//  IntercomDelegate.swift
//
//
//  Created by Jean Sarda on 16/08/2024.
//

import Foundation

public protocol IntercomDelegate: AnyObject {
    
    func sessionActivated(isPaired: Bool)
}
