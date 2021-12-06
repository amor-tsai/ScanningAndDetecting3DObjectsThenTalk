//
//  ConversationButton.swift
//  ScanningApp
//
//  Created by Amor on 2021/12/4.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
@IBDesignable

class ShareButton: RoundedButton{
        
    override func setup() {
        backgroundColor = .appBlue
        layer.cornerRadius = 8
        clipsToBounds = true
        setTitleColor(.white, for: [])
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitle("Share", for: [])
    }
}
