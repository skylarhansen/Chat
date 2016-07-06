//
//  Message.swift
//  Chat
//
//  Created by Skylar Hansen on 7/2/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation
import CloudKit

class Message {
    
    static let kType = "Message"
    static let kThread = "thread"
    static let kText = "text"
    static let kDateCreated = "dateCreated"
    static let kCreator = "creator"
    
    let thread: Thread
    let text: String
    let dateCreated: NSDate
    let creator: String
    
    init(thread: Thread, text: String, dateCreated: NSDate = NSDate(), creator: String) {
        
        self.thread = thread
        self.text = text
        self.dateCreated = dateCreated
        self.creator = creator
    }
    
    // MARK: - CloudKitSyncable
    
    var recordType: String = Message.kType
    
    var cloudKitRecord: CKRecord? {
        let record = CKRecord(recordType: recordType)
        
        record[Message.kThread] = thread
    }
}