//
//  OmeletSearchTableViewCell.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import UIKit

class OmeletSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thubnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thubnailImageView?.layer.cornerRadius = 60/2
        thubnailImageView?.clipsToBounds = true
        backgroundColor = .clear
    }
}
