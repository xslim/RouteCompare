//
//  WildcardGestureRecognizer.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 25/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
//import UIKit.UIGestureRecognizerSubclass

typealias WildcardGestureRecognizerHandler = ( touches: NSSet, event: UIEvent) -> ()

class WildcardGestureRecognizer: UIGestureRecognizer {
    
    var handler:WildcardGestureRecognizerHandler?
    
    init(target: AnyObject!, action: Selector) {
        super.init(target: target, action: action)
        self.cancelsTouchesInView = false
    }
    
    
    init(handler: WildcardGestureRecognizerHandler) {
        super.init(target: nil, action: nil)
        self.handler = handler
        self.cancelsTouchesInView = false
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // do your stuff
        self.state = .Began
        self.handler?(touches: touches, event: event)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)  {
        
    }
    
    override func reset() {
        
    }
    
    override func ignoreTouch(touch: UITouch!, forEvent event: UIEvent!)  {
        
    }
    
    override func canBePreventedByGestureRecognizer(preventingGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false
    }
    
    override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer!) -> Bool  {
        return false
    }

    
}
