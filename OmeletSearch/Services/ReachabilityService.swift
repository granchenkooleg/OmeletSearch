//
//  ReachabilityService.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/26/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable:
                print("The network is not reachable")
            case .unknown:
                print("It is unknown whether the network is reachable")
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
            }
        }
        reachabilityManager?.startListening()
    }
    
    public func isReachable() -> Bool {
        if reachabilityManager!.isReachable {
            return true
        } else {
            print ("isReachable is returning false")
            return false
        }
        //        return reachabilityManager?.isReachable ?? false
    }
}

