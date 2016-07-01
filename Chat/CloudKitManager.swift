//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Skylar Hansen on 6/15/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class CloudKitManager {
    
    private let creationDateKey = "creationDate"
    
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    init() {
        checkCloudKitAvailability()
        //requestDiscoverabilityPermission()
    }
    
    // MARK: - User Info Discovery
    
    func fetchLoggedInUserRecord(completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            if let error =  error,
                let completion = completion {
                completion(record: nil, error: error)
            }
            
            if let recordID = recordID,
                let completion = completion {
                self.fetchRecordWithID(recordID, completion: { (record, error) in
                    completion(record: record, error: error)
                })
            }
        }
    } // If I am logged in, it will fetch my record (FN 2817)
    
    func fetchUsernameFromRecordID(recordID: CKRecordID, completion: ((firstName: String?, lastName: String?) -> Void)?) {
        let operation = CKDiscoverUserInfosOperation(emailAddresses: nil, userRecordIDs: [recordID])
        
        operation.discoverUserInfosCompletionBlock = { (emailsToUserInfos, userRecordIDsToUserInfos, operationError) -> Void in
            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
                let userInfo = userRecordIDsToUserInfos[recordID],
                let completion = completion {
                completion(firstName: userInfo.displayContact?.givenName, lastName: userInfo.displayContact?.familyName)
            } else if let completion = completion {
                completion(firstName: nil, lastName: nil)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    } // From FN 2817 we get Finn(this is all stars wars stuff)
    
    func fetchAllDiscoverableUsers(completion: ((userInfoRecords: [CKDiscoveredUserInfo]?) -> Void)?) {
        
        let operation = CKDiscoverAllContactsOperation()
        
        operation.discoverAllContactsCompletionBlock = { (discoveredUserInfos, error) -> Void in
            
            if let completion = completion {
                completion(userInfoRecords: discoveredUserInfos)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    } // Get all the Storm Troopers
    
    // MARK: - Fetch Records
    
    func fetchRecordWithID(recordID: CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    } // Brings back the record for whatever item has that ID (starship blaster, trooper, etc.)
    
    func fetchRecordsWithType(type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((record: CKRecord) -> Void)? = nil, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            recordFetchedBlock?(record: fetchedRecord)
        }
        
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            if let queryCursor = queryCursor {
                // There are more results, go fetch them, the queryCursor only exists if there are more 'posts' that need to be brought down, when cursor returns nil then it completes. The cursor is like a bookmark, it says, I left off at record 100 so next time I need to start at 101.
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                self.publicDatabase.addOperation(continuedQueryOperation)
            } else {
                // All done getting the records
                completion?(records: fetchedRecords, error: error)
            }
        }
        
        publicDatabase.addOperation(queryOperation)
        
    } // brings back all records of that type (all trooper records, all helmet records)
    
    func fetchCurrentUserRecords(type: String, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        fetchLoggedInUserRecord { (record, error) in
            // TODO: Handle Error
            if let record = record {
                let predicate = NSPredicate(format: "%K == %@", argumentArray: ["creatorUserRecordID", record.recordID])
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    // handle the error
                    if let completion = completion {
                        completion(records: records, error: error)
                    }
                })
            }
        }
    } // calls for logged in user's record, and then all of the records that belong to that specific user. Get's Finn from his record, and then all records associated with him
    
    func fetchRecordsFromDateRange(type: String, fromDate: NSDate, toDate: NSDate, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [creationDateKey, fromDate])
        let endDatePredicate = NSPredicate(format: "%K < %@", argumentArray: [creationDateKey, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    } // all helmet/trooper/starship records from this start date to this end date
    
    // MARK: - Delete
    
    func deleteRecordWithID(recordID: CKRecordID, completion: ((recordID: CKRecordID?, error: NSError?) -> Void)?) {
        publicDatabase.deleteRecordWithID(recordID) { (recordID, error) in
            if let completion = completion {
                completion(recordID: recordID, error: error)
            }
        }
    } // whatever record the ID belongs to, the record is destroyed. (what if your Social Security Record got destroyed?)
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((records: [CKRecord]?, recordIDs: [CKRecordID]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.queuePriority = .High
        operation.savePolicy = .IfServerRecordUnchanged
        operation.qualityOfService = .UserInitiated
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let completion = completion {
                completion(records: records, recordIDs: recordIDs, error: error)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    } // find the younglings for these IDs, and kill them.
    
    // MARK: - Save and Modify
    
    func saveRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        modifyRecords(records, perRecordCompletion: perRecordCompletion) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    func saveRecord(record: CKRecord, completion: ((record: CKRecord?, error: NSError?) -> Void)? = nil) {
        publicDatabase.saveRecord(record) { (record, error) in
            completion?(record: record, error: error)
        }
    }
    
    func modifyRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.queuePriority = .High
        operation.savePolicy = .ChangedKeys
        operation.qualityOfService = .UserInteractive
        
        operation.perRecordCompletionBlock = { (record, error) -> Void in
            if let perRecordCompletion = perRecordCompletion {
                perRecordCompletion(record: record, error: error)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void  in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
        
        publicDatabase.addOperation(operation)
        
    } // updating records. If Finn went to the dentist, update his dental record. Finn took off his helmet, update his mental heath record
    
    // MARK: - Subscriptions
    
    func subscribe(type: String, predicate: NSPredicate = NSPredicate(value: true), subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        if alertBody != nil { notificationInfo.soundName = UILocalNotificationDefaultSoundName }
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.saveSubscription(subscription) { (subscription, error) in
            completion?(subscription: subscription, error: error)
        }
    }
    
    func unsubscribe(subscriptionID: String, completion: ((subscriptionID: String?, error: NSError?) -> Void)?) {
        
        publicDatabase.deleteSubscriptionWithID(subscriptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                completion(subscriptionID: subscriptionID, error: error)
            }
        }
    }
    
    func fetchSubscriptions(completion: ((subscriptions: [CKSubscription]?, error: NSError?) -> Void)?) {
        
        publicDatabase.fetchAllSubscriptionsWithCompletionHandler { (subscriptions, error) in
            
            if let completion = completion {
                completion(subscriptions: subscriptions, error: error)
            }
        }
    }
    
    func fetchSubscription(subscriptionID: String, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        
        publicDatabase.fetchSubscriptionWithID(subscriptionID) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription: subscription, error: error)
            }
        }
    }
    
    // MARK: - CloudKit Permissions
    
    func checkCloudKitAvailability() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus: CKAccountStatus, error: NSError?) in
            switch accountStatus {
            case .Available:
                print("CloudKit avaialbe")
            default:
                self.handleCloudKitUnavailable(accountStatus, error: error)
            }
        }
    } // is it available?
    
    func handleCloudKitUnavailable(accountStatus: CKAccountStatus, error: NSError?) {
        var errorText = "Sync is disabled \n"
        if let error = error {
            errorText += error.localizedDescription
        }
        
        switch accountStatus {
        case .Restricted:
            errorText += "iCloud is not available due to restrictions"
        case .NoAccount:
            errorText += "There is no iCloud account set up. \n You can set up iCloud in the Settings app"
        default:
            break
        }
        displayCloudKitNotAvailableError(errorText)
    } // Prepare your excuse for why it's not working, find out what to say
    
    func displayCloudKitNotAvailableError(errorText: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "iCloud Sync Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    } // Giving your excuse
    
    // MARK: - CloudKit Discoverability
    
    func requestDiscoverabilityPermission() {
        CKContainer.defaultContainer().statusForApplicationPermission(.UserDiscoverability) { (permissionStatus, error) in
            if permissionStatus == .InitialState {
                CKContainer.defaultContainer().requestApplicationPermission(.UserDiscoverability, completionHandler: { (permissionStatus, error) in
                    self.handleCloudKitPermissionStatus(permissionStatus, error: error)
                })
            } else {
                self.handleCloudKitPermissionStatus(permissionStatus, error: error)
            }
        }
    } // Can you play? Are you available?
    
    func handleCloudKitPermissionStatus(permissionStatus: CKApplicationPermissionStatus, error: NSError?) {
        if permissionStatus == .Granted {
            print("User Discoverability permission granted. User may proceed with full access")
        } else {
            var errorText = "Sync is disabled \n"
            if let error = error {
                errorText += error.localizedDescription
            }
            switch permissionStatus {
            case .Denied:
                errorText += "You have denied User Discoverability permissions. You may be unable to use certain features that require User Discoverability."
            case .CouldNotComplete:
                errorText += "Unable to verify User Discoverability permissions. You may have a connectivity issue. Please try again."
            default:
                break
            }
            displayCloudKitPermissionNotGrantedError(errorText)
        }
    } // find out Y/N of availability. If N, prepare excuse
    
    func displayCloudKitPermissionNotGrantedError(errorText: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "CloudKit Permission Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    } // break it to them, give your excuse
    
}


