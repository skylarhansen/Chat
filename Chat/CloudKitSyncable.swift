//
//  CloudKitSyncable.swift
//  Chat
//
//  Created by Skylar Hansen on 6/30/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation
import CloudKit

@objc protocol CloudKitSyncable {
    
    var timestamp: NSDate { get set }
    var recordIDData: NSData? { get set }
    var recordName: String { get set }
    var recordType: String { get }
    
    var cloudKitRecord: CKRecord? { get }
    
    init?(record: CKRecord)
}

extension CloudKitSyncable {
    
    var cloudKitRecordID: CKRecordID? {
        
        guard let recordIDData = recordIDData,
            recordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID else { return nil }
        
        return recordID
    }
    
    var cloudKitReference: CKReference? {
        
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: recordID, action: .None)
    }
    
    func update(record: CKRecord) {
        
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    func nameForSyncableObject() -> String {
        
        return NSUUID().UUIDString
    }
}