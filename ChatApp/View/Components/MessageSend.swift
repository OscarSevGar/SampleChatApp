//
//  MessageSent.swift
//  ChatApp
//
//  Created by Etwan on 11/07/24.
//

import UIKit

class MessageSend: UITableViewCell {

    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
}
