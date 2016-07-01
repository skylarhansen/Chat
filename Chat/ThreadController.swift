//
//  ThreadController.swift
//  Chat
//
//  Created by Skylar Hansen on 6/30/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation

class ThreadController {
    
    func createThread(names: String, messages: [Message], completion: (() -> Void)?) {
        
    }
    
    func deleteThread(thread: Thread, completion: (() -> Void)?) {
        
    }
    
    func addMessageToThread(message: Message, thread: Thread, completion: ((success: Bool) -> Void)?) {
        
    }
    
    func removeMessageFromThread(message: Message, thread: Thread, completion: (() -> Void)?) {
        
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save context: \(error)")
        }
    }
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        
        return []
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        
        return []
    }
    
    func newRecords() {
        
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
    }
    
    // Subscriptions
    
    func subscribeToNewThread(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
    }
    
    func checkSubscription(thread: Thread, completion: ((subscribed: Bool) -> Void)?) {
        
    }
    
//    func addSubscription() {
//        
//    }
    
//    func removeSubscription() {
//        
//    }
}