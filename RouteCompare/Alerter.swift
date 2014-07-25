//
//  Alerter.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import UIKit

class Alerter {
    class func UIAlert(title:String, msg: String?) {
        if !msg {
            UIAlertView(title: nil, message: title, delegate: nil, cancelButtonTitle: "OK")
        } else {
            UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "OK")
        }
        
    }
}