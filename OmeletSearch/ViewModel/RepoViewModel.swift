//
//  RepoViewModel.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import Foundation

class RepoViewModel {
    private var repo = Repo()
    
    var repoTitle: String {
        return repo.title
    }
    
    var repoHref: String {
        return repo.href
    }
    
    var repoOmeletTitle: String {
        return repo.results.first?.title ?? ""
    }
    
    var repoOmeletIngredients: String {
        return repo.results.first?.ingredients ?? ""
    }
    
    var repoOmeletThumbnail: String {
        return repo.results.first?.thumbnail ?? ""
    }
    
    var repoOmeletHref: String {
        return repo.results.first?.href ?? ""
    }
    
}
