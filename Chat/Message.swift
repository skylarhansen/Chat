//
//  Message.swift
//  Chat
//
//  Created by Skylar Hansen on 6/30/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation
import CoreData


class Message: SyncableObject {
    
    static let kType = "Message"
    static let kThread = "thread"
    static let kText = "text"
    static let kSender = "sender"
    static let kTimestamp = "timestamp"
    
    convenience init(thread: Thread, text: String, sender: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName(Message.kType, inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description")
            
            
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.thread = thread
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        
    }
}
