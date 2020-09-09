//
//  NewsClient.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import Foundation
import Moya

class NewsClient {
    let provider: MoyaProvider<NewsTarget>
    var nextPageFromDate = Date()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    init(provider: MoyaProvider<NewsTarget> = MoyaProvider<NewsTarget>(), latestDate: Date = Date()) {
        self.provider = provider
        self.nextPageFromDate = latestDate
    }
    
    /// Fetch lastest news
    func fetchNews(onSuccess: @escaping (_ articles: [ArticleModel]) -> (),
                   onError: @escaping (_ error: Error) -> ()) {
        provider.request(.fetchNews(before: Date())) { [unowned self] in
            switch $0 {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let data = filteredResponse.data
                    
                    let news = try self.decoder.decode(NewsModel.self, from: data)
                    if let lastFetchedDate = news.articles.last?.publishedAt, lastFetchedDate < self.nextPageFromDate {
                        self.nextPageFromDate = lastFetchedDate
                    }
                    onSuccess(news.articles)
                } catch {
                    onError(error)
                }
                
            case .failure(let error):
                print(error)
                onError(error)
            }
        }
    }
    
    ///Fetch news with date cursor
    func fetchNextPage(onSuccess: @escaping (_ articles: [ArticleModel]) -> (),
                       onError: @escaping (_ error: Error) -> ()) {
        provider.request(.fetchNews(before: nextPageFromDate)) { [unowned self] in
            switch $0 {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let data = filteredResponse.data
                    
                    let news = try self.decoder.decode(NewsModel.self, from: data)
                    if let lastFetchedDate = news.articles.last?.publishedAt, lastFetchedDate < self.nextPageFromDate {
                        self.nextPageFromDate = lastFetchedDate
                    }
                    onSuccess(news.articles)
                } catch {
                    onError(error)
                }
                
            case .failure(let error):
                print(error)
                onError(error)
            }
        }
    }
}
