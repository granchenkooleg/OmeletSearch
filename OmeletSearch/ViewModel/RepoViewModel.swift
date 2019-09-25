//
//  RepoViewModel.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

class RepoViewModel {
    
    private var repos: Results<OmeletResult>?
    public var changesObservable = PublishSubject<Array<OmeletResult>>()
    fileprivate let bag = DisposeBag()
    init() {
        Repo.setConfig()
        
        let realm = try! Realm()
        repos = realm.objects(OmeletResult.self)
        
        Observable.changeset(from: repos!)
            .subscribe(onNext: { [weak self] results, changes in
                self?.changesObservable.onNext(Array(results))
            }).disposed(by: bag)
    }
    
    var input: Observable<String>? {
        willSet {
            if true {
                newValue?.map { URL.bestOmeletSearch($0) }
                    .do(onNext: { _ in UIApplication.shared.isNetworkActivityIndicatorVisible = true })
                    .flatMapLatest { url in
                        return URLSession.shared.rx.json(url: url)
                            .observeOn(MainScheduler.instance)
                            .catchErrorJustReturn([])
                    }
                    .do(onNext: { _ in UIApplication.shared.isNetworkActivityIndicatorVisible = false })
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1)))
                    .map {json -> [Repo] in
                        guard let json = json as? [String: AnyObject] else {return []}
                        return [Repo(value: json)]
                    }
                    .subscribe(onNext: { repos in
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(repos, update: .modified)
                        }
                    }).disposed(by: bag)
            } else {
                let realm = try! Realm()
                repos = realm.objects(OmeletResult.self)
                changesObservable.onNext(Array(repos!))
            }
            
        }
    }
}
