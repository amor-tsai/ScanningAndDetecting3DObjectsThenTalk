//
//  SpeechButton.swift
//  ScanningApp
//
//  Created by Amor on 2021/12/6.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
@IBDesignable

class SpeechButton: RoundedButton{
    
    override var toggledOn:Bool {
        didSet{
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
            if toggledOn {
                self.setImage(UIImage(systemName: "mic.fill", withConfiguration: largeConfig), for: .normal)
                self.backgroundColor = UIColor.gray
                
            } else {
                self.setImage(UIImage(systemName: "mic", withConfiguration: largeConfig), for: .normal)
                self.backgroundColor = UIColor.blue
            }
        }
    }
    
    override func setup() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        clipsToBounds = true
        setTitleColor(.white, for: [])
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }

}
