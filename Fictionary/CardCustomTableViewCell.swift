//
//  CardCustomTableViewCell.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/13/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class CardCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
