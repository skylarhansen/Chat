//
//  ThreadTableViewController.swift
//  Chat
//
//  Created by Skylar Hansen on 6/30/16.
//  Copyright © 2016 Skylar Hansen. All rights reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(threadsWereUpdated(_:)), name: ThreadController.didRefreshNotification, object: nil)
    }
    
    func threadsWereUpdated(notification: NSNotification) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ThreadController.sharedController.threads.count
    }

    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath)
        
        let threads = ThreadController.sharedController.threads
        let thread = threads[indexPath.row]
        
        cell.textLabel?.text = thread.displayName
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(thread.timestamp)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let thread = ThreadController.sharedController.threads[indexPath.row]
            ThreadController.sharedController.deleteThread(thread, completion: nil)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    } 

    // MARK: - Navigation

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "toMessageDetail" {
//            if let detailViewController = segue.destinationViewController as? MessageViewController,
//            let selectedIndexPath = self.tableView.indexPathForSelectedRow,
//            let post = 
//        }
//    }

}
