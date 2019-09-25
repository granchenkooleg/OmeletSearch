//
//  URL + ext.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import Foundation

// Factory method for urls
extension URL {
    static func listOmelets() -> String {
        return "​http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3"
    }
    
    static func bestOmeletSearch(_ query: String) -> URL {
        let query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return URL(string: "http://www.recipepuppy.com/api/?q=\(query)")!
    }
}
