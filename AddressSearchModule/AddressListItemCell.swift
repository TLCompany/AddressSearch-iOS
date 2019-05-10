//
//  AddressResultItemCell.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit

final class AddressListItemCell: UITableViewCell {
    static public let id = "AddressListItemId"
    
    @IBOutlet private weak var jibunAddrsLabel: UILabel!
    @IBOutlet private weak var roadNameAddrsLabel: UILabel!
    
    public var address: Address? {
        didSet {
            guard let jbAddrs = address?.jibunAddr, let rdAddrs = address?.roadAddr else { return }
            jibunAddrsLabel.text = jbAddrs
            roadNameAddrsLabel.text = rdAddrs
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
