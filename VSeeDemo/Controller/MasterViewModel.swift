//
//  ViewModel.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

protocol MasterViewModelDelegate: class {
    func dbDidChange(changes: RealmCollectionChange<Results<ArticleRealm>>)
    func onError(_ error: Error)
}

class MasterViewModel {
    private weak var delegate: MasterViewModelDelegate?
    private var newsClient: NewsClient
    
    private var realm = try! Realm()
    lazy var articles = realm.objects(ArticleRealm.self).sorted(byKeyPath: "publishedAt", ascending: false)
    var notificationToken: NotificationToken? = nil
    
    init(delegate: MasterViewModelDelegate, newsClient: NewsClient = NewsClient()) {
        self.delegate = delegate
        self.newsClient = newsClient
        newsClient.nextPageFromDate = articles.last?.publishedAt ?? Date()
        
        notificationToken = articles.observe { [weak self] (changes: RealmCollectionChange) in
            self?.delegate?.dbDidChange(changes: changes)
        }
    }
    
    /// Load the news from API
    func load(completion: (() -> ())? = nil) {
        newsClient.fetchNews(onSuccess: { [weak self] (articlesModel) in
            self?.addToDb(models: articlesModel)
            completion?()
        }) { [weak self] (error) in
            print(error)
            completion?()
            self?.delegate?.onError(error)
        }
    }
    
    /// Load the news from API from lastest date
    func loadMore(completion: (() -> ())?) {
        newsClient.fetchNextPage(onSuccess: { [weak self] (articlesModel) in
            self?.addToDb(models: articlesModel)
            completion?()
        }) { [weak self] (error) in
            print(error)
            completion?()
            self?.delegate?.onError(error)
        }
    }
    
    /// Save and notify the controller to update
    func addToDb(models: [ArticleModel]) {
        do {
            let realmArticles = models.map(ArticleRealm.init)
            
            try self.realm.write {
                self.realm.add(realmArticles, update: .modified)
            }
        } catch {
            self.delegate?.onError(error)
        }
    }
}
