//
//  ViewController.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import UIKit
import TVNExtensions
import RealmSwift
import Hero

class MasterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 150
            tableView.rowHeight = UITableView.automaticDimension
            tableView.tableFooterView = UIView()
        }
    }
    lazy var refreshControl: UIRefreshControl = {
        let v = UIRefreshControl()
        return v
    }()
    
    lazy var viewModel: MasterViewModel = MasterViewModel(delegate: self)
    lazy var loadMoreIndicator: LoadMoreActivityIndicator = LoadMoreActivityIndicator(scrollView: tableView,
                                                                                      spacingFromLastCell: 10,
                                                                                      spacingFromLastCellWhenLoadMoreActionStart: 60)
    
    lazy var detailSplitVC: DetailViewController? = {
       if let splitVC = self.splitViewController,
        let detailNavVC = splitVC.viewControllers.last as? UINavigationController,
        let detailVC = detailNavVC.topViewController as? DetailViewController {
            return detailVC
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.load()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if let detailVC = detailSplitVC, let article = viewModel.articles.first {
            detailVC.article = article //Supply first data in iPad mode
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        viewModel.load {
            sender.endRefreshing()
        }
    }
}

extension MasterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ArticleTableViewCell.self, for: indexPath)
        cell.bind(article: viewModel.articles[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load more upon the end of list
        loadMoreIndicator.start {
            DispatchQueue.global(qos: .utility).async {
                self.viewModel.loadMore {
                    DispatchQueue.main.async { [weak self] in
                        self?.loadMoreIndicator.stop()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let detailVC = detailSplitVC {
            //iPad split view
            detailVC.article = viewModel.articles[indexPath.row]
            detailVC.bind()
        } else {
            let detailVC = DetailViewController.instantiate()
            detailVC.article = viewModel.articles[indexPath.row]
            
            self.navigationController?.isHeroEnabled = true
            self.navigationController?.heroNavigationAnimationType = .autoReverse(presenting: .slide(direction: .left))
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension MasterViewController: MasterViewModelDelegate {
    func dbDidChange(changes: RealmCollectionChange<Results<ArticleRealm>>) {
        switch changes {
        case .initial:
            tableView.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            tableView.beginUpdates()
            tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                 with: .automatic)
            tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                 with: .automatic)
            tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                 with: .automatic)
            tableView.endUpdates()
        case .error(let error):
            print(error)
        }
    }
    
    func onError(_ error: Error) {
        UILabel.showTooltip(error.localizedDescription)
    }
}

