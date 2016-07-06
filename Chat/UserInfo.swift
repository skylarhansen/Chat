//
//  UserInfo.swift
//  Chat
//
//  Created by Skylar Hansen on 7/2/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation

class UserInfo {
    
    let firstName: String
    let lastName: String
    let threads: [Thread]
    
    init(firstName: String, lastName: String, threads: [Thread]) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.threads = threads
    }
}