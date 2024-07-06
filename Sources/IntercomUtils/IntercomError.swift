//
//  File.swift
//  
//
//  Created by Jean Sarda on 05/07/2024.
//

import Foundation

public enum IntercomError: Error {
    case sessionNotActivated
    case noContextInUserInfoDictionary
    case unsupportedCommand
}
