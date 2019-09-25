//
//  Repo.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class OmeletResult: Object {
    dynamic var title = ""
    dynamic var href = ""
    dynamic var ingredients = ""
    dynamic var thumbnail = ""
    
    override class func primaryKey() -> String? {
        return "title"
    }
}

@objcMembers class Repo: Object {
    dynamic var title = ""
    dynamic var href = ""
    var results = List<OmeletResult>()
    
    
    override class func primaryKey() -> String? {
        return "title"
    }
    
    // Path to Realm file
    static func setConfig() {
        let realm = try! Realm()
        if let url = realm.configuration.fileURL {
            print("FileURL of DataBase - \(url)")
        }
    }
}

