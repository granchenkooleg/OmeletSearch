//
//  OmeletSearchViewController.swift
//  OmeletSearch
//
//  Created by Oleg Granchenko on 9/25/19.
//  Copyright © 2019 Oleg Granchenko. All rights reserved.
//

import UIKit
import SDWebImage

import RxSwift
import RxCocoa

import RealmSwift
import RxRealm

// Factory method for urls
extension URL {
    static func listOmelets() -> URL {
        return URL(string: "​http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")!
    }
    
    static func bestOmeletSearch(_ query: String) -> URL {
        let query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return URL(string: "http://www.recipepuppy.com/api/?q=\(query)")!
    }
}

class OmeletSearchViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var query: UITextField!
    
    //MARK: - Properties
    private var viewModel = RepoViewModel()
    fileprivate let bag = DisposeBag()
    fileprivate var resultsBag = DisposeBag()
    
    fileprivate var repos: Results<OmeletResult>?
    
    private let cellId = "RepoCell"
    
    //MARK: - Bind UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        Repo.setConfig()
        
        //define input
        let input = query.rx.text
            .filter {($0?.utf8.count ?? 0) > 2}
            .share(replay: 1)
        
        //call API method, save to Realm
        input.throttle(0.5, scheduler: MainScheduler.instance)
            .map { URL.bestOmeletSearch($0 ?? "")}
            .do(onNext: { _ in UIApplication.shared.isNetworkActivityIndicatorVisible = true })
            .flatMapLatest { url in
                return URLSession.shared.rx.json(url: url).catchErrorJustReturn([])
            }
            .do(onNext: { _ in UIApplication.shared.isNetworkActivityIndicatorVisible = false })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1)))
            .map {json -> [Repo] in
                guard let json = json as? [String: AnyObject] else {return []}
                return [Repo(value: json)]
            }
            .subscribe(onNext: {repos in
                let realm = try! Realm()
                try! realm.write {
                    realm.add(repos, update: true)
                }
            })
            .disposed(by: bag)
        
        //bind results to table
        input.subscribe(onNext: {[weak self] in
            self?.bindTableView($0)
        })
            .disposed(by: bag)
        
        //reset table
        query.rx.text.filter { ($0?.utf8.count ?? 0) <= 2}
            .subscribe(onNext: {[weak self] _ in
                self?.bindTableView(nil)
            })
            .disposed(by: bag)
    }
    
    private func setupTableView() {
        // Resize dynamic cell
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    /// bind results to table view
    func bindTableView(_ term: String?) {
        resultsBag = DisposeBag()
        
        guard let term = term else {
            repos = nil
            tableView.reloadData()
            return
        }
        
        let realm = try! Realm()
        repos = realm.objects(OmeletResult.self)
            .filter("title CONTAINS[c] %@", term)
        
        Observable.changeset(from: repos!)
            .subscribe(onNext: { [weak self] results, changes in
                guard let tableView = self?.tableView else { return }
                
                if let changes = changes {
                    tableView.beginUpdates()
                    tableView.insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) },
                                         with: .automatic)
                    tableView.endUpdates()
                } else {
                    tableView.reloadData()
                }
                
            })
            .disposed(by: resultsBag)
    }
}

//MARK: - Extension
extension OmeletSearchViewController: UITableViewDataSource {
    //MARK: - UITableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! OmeletSearchTableViewCell
        let repo = repos![indexPath.row]
        
        DispatchQueue.main.async {
            cell.thubnailImageView.sd_setImage(with: URL(string: repo.thumbnail), placeholderImage: UIImage(named: "omlette.png"))
        }
        cell.titleLabel.text = repo.title
        cell.ingredientsLabel.text = repo.ingredients
        return cell
    }
}


