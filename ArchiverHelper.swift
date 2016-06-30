//
//  ArchiveData.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class ArchiverHelper: NSObject {

    func archiveData(data data: AnyObject) -> NSData? {
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(data)
        
        return archivedData
    }
    
    func unarchiveData(data data: NSData) -> AnyObject? {
        let unarchivedData = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        
        return unarchivedData
    }
    
}