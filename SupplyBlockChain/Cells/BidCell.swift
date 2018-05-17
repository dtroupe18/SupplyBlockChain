//
//  BidCell.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/16/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class BidCell: UITableViewCell {
    
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bidderNameLabel: UILabel!
    @IBOutlet weak var bidderEmailLabel: UILabel!
    @IBOutlet weak var bidderPhoneLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
