//
//  ArchiveData.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class ArchiverHelper: NSObject {

    // This function allows you to pass in an NSDictionary that you want to send through a message and returns an NSData object that can be sent to the other devices.
    func archiveData(data data: NSDictionary) -> NSData? {
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(data)
        
        return archivedData
    }
    
    // This function takes in the NSData that is received from other devices and unwraps it into an NSDictionary optional which we can use to handle the incoming data.
    func unarchiveData(data data: NSData) -> NSDictionary? {
        let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
        
        return unarchivedData
    }
    
}