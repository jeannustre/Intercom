//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import Foundation
import IntercomUtils

extension IntercomPhone {
    
    func isComplicationEnabled() throws -> Bool {
        guard sessionActivated else {
            throw IntercomError.sessionNotActivated
        }
        return session.isComplicationEnabled
    }
    
    func isPaired() throws -> Bool {
        guard sessionActivated else {
            throw IntercomError.sessionNotActivated
        }
        return session.isPaired
    }
    
    func isWatchAppInstalled() throws -> Bool {
        guard sessionActivated else {
            throw IntercomError.sessionNotActivated
        }
        return session.isWatchAppInstalled
    }
}
