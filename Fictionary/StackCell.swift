//
//  StackCell.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

protocol StackCellDelegate {
    func rowWasSelectedForImage(_ imageNamed: String)
}

class StackCell: UICollectionViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    // this is the array for the ONE CELL.  This should only be defined once for this page as it will change for each cell
    var array = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
    
    var delegate: StackCellDelegate?
    
    func rowWasSelectedForImage(_ imageNamed: String) {
        delegate?.rowWasSelectedForImage(imageNamed)
    }

}

    extension StackCell: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return array.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            cell.cardImageView?.image = UIImage(named: array[indexPath.row])
            tableView.rowHeight = 100
            return cell
        }
        
    
    }

    extension StackCell: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("didSelectRowAtIndexPath: \(indexPath) - \(array[indexPath.row])")
            print("from: \(array)")
//            self.messageLabel.text = array[indexPath.row]
            
            rowWasSelectedForImage("\(array[indexPath.row])")
            
        }
        
    }






