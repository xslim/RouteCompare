//
//  Extensions.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation


extension Array {
    var last: T {
//        if self.count == 0 {
//            return nil
//        }
    
        return self[self.endIndex - 1]
    }
}