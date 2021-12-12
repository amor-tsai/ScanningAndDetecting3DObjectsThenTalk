//
//  SpeechBubble.swift
//  ScanningApp
//
//  Created by Amor on 2021/12/6.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import SceneKit

// at first I intend to create a SCNText chat bubble, but after I saw the image from internet, I give up. I think using label is more readily to read.
class SpeechBubble: SCNNode{

    var text:String? {
        didSet {
            textNode.string = text
        }
    }
    
    private var textNode = SCNText()
    
    override init() {
        super.init()
        
        textNode.extrusionDepth = 0.1
        textNode.font = UIFont.boldSystemFont(ofSize: 17)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
