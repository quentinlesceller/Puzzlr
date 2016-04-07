//
//  ContactTableViewCell.swift
//  Puzzlr
//
//  The contact table view cell.
//
//  Created by Quentin Le Sceller on 29/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

  
    @IBOutlet weak var nameLabel: UILabel!
    
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        override func setSelected(selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Configure the view for the selected state
        }
        
}