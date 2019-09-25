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

class OmeletSearchViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var query: UITextField!
    
    //MARK: - Properties
    private var viewModel = RepoViewModel()
    fileprivate let bag = DisposeBag()
    fileprivate var resultsBag = DisposeBag()
    
    private var repos = [OmeletResult]()
    
    private let cellId = "RepoCell"
    
    //MARK: - Bind UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        //define input
        viewModel.input = query.rx.text.orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { $0.utf8.count > 2 }
            .share(replay: 1)
        
        query.rx.text.orEmpty.filter { $0.utf8.count <= 2}
            .subscribe(onNext: {[weak self] _ in
                self?.repos.removeAll()
                self?.tableView.reloadData()
            }).disposed(by: bag)
    }
    
    private func setupTableView() {
        // Resize dynamic cell
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        
        viewModel.changesObservable
            .subscribe(onNext: { [unowned self] result in
                self.repos.removeAll()
                if let text = self.query.text, !text.isEmpty {
                    self.repos = result.filter({ $0.title.lowercased().contains(text.lowercased()) })
                } else {
                    self.repos = result
                }
                self.tableView.reloadData()
            }).disposed(by: bag)
        viewModel.input = Observable.just(URL.listOmelets())
    }
}


//MARK: - Extension
extension OmeletSearchViewController: UITableViewDataSource {
    //MARK: - UITableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! OmeletSearchTableViewCell
        let repo = repos[indexPath.row]
        
        DispatchQueue.main.async {
            cell.thubnailImageView.sd_setImage(with: URL(string: repo.thumbnail), placeholderImage: UIImage(named: "omlette.png"))
        }
        cell.titleLabel.text = repo.title
        cell.ingredientsLabel.text = repo.ingredients
        return cell
    }
}


