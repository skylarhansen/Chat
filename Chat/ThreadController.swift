//
//  ThreadController.swift
//  Chat
//
//  Created by Skylar Hansen on 6/30/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import Foundation
import CloudKit

class ThreadController {
    
    let cloudKitManager = CloudKitManager()
    
    static let sharedController = ThreadController()
    
    static let didRefreshNotification = "ThreadControllerDidRefreshNotification"
    
    private(set) var threads: [Thread] = [] {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(ThreadController.didRefreshNotification, object: self)
            })
        }
    }
    
    func createThread(displayName: String, creator: String, completion: (() -> Void)?) {
        let thread = Thread(displayName: displayName, creator: creator)
        guard let threadRecord = thread.cloudKitRecord else { return }
        cloudKitManager.saveRecord(threadRecord) { (record, error) in
            if let error = error {
                NSLog("Error saving \(thread) to CloudKit: \(error)")
                return
            }
            self.threads.append(thread)
            thread.recordID = record?.recordID
            
        }
    }
    
    func deleteThread(thread: Thread, completion: (() -> Void)?) {
        let thread = thread
        guard let threadRecordID = thread.cloudKitRecordID else { return }
        cloudKitManager.deleteRecordWithID(threadRecordID) { (recordID, error) in
            if let error = error {
                NSLog("Error removing \(thread) from CloudKit: \(error)")
            }
            if let index = self.threads.indexOf(thread) {
                self.threads.removeAtIndex(index)
            }
        }
    }
    
    func addMessageToThread(thread: Thread, text: String, creator: UserInfo, completion: ((success: Bool) -> Void)?) {
        
        let message = Message(thread: thread, text: text, creator: creator)
        
        
    }
    
    func removeMessageFromThread(message: Message, thread: Thread, completion: (() -> Void)?) {
        
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
}