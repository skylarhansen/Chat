//
//  Thread.swift
//  Chat
//
//  Created by Skylar Hansen on 7/2/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation
import CloudKit

class Thread: CloudKitSyncable, Equatable {
    
    static let kType = "Thread"
    static let kDisplayName = "displayName"
    static let kTimestamp = "timestamp"
    static let kCreator = "creator"
    
    let displayName: String
    var timestamp: NSDate
    let creator: String
    var recordName: String
    var recordID: CKRecordID?
    
    init(displayName: String, timestamp: NSDate = NSDate(), creator: String) {
        
        self.displayName = displayName
        self.timestamp = timestamp
        self.creator = creator
        self.recordName = self.nameForSyncableObject()
    }
    
    // MARK: - CloudKit
    
    var recordType: String = Thread.kType
    
    var cloudKitRecord: CKRecord? {
        
        let record = CKRecord(recordType: recordType)
        
        record[Thread.kDisplayName] = displayName
        record[Thread.kTimestamp] = timestamp
        record[Thread.kCreator] = creator
        
        return record
    }
    
    convenience required init?(record: CKRecord) {
        guard let timestamp = record.creationDate else { return nil }
        
        self.timestamp = timestamp
        self.recordName = record.recordID.recordName
//        self.recordID = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
//        self.init(displayName: String, timestamp: NSDate = NSDate(), creator: String)
        
    }
}

func ==(lhs: Thread, rhs: Thread) -> Bool {
    return lhs.displayName == rhs.displayName && lhs.timestamp == rhs.timestamp && lhs.creator == rhs.creator && lhs.recordName == rhs.recordName && lhs.recordID == rhs.recordID
}