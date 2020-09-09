//
//  Article.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - Db Article
class ArticleRealm: Object {
    @objc dynamic var author: String? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var articleDescription: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var urlToImage: String? = nil
    @objc dynamic var publishedAt: Date = Date()
    @objc dynamic var content: String? = nil
    
    var urlParsed: URL {
       return URL(string: url)!
    }
    
    var urlToImageParsed: URL? {
       return URL(string: urlToImage ?? "")
    }
    
    override static func primaryKey() -> String? {
        return "url"
    }
    
    convenience init(from model: ArticleModel) {
        self.init()
        title = model.title
        author = model.source.name
        articleDescription = model.articleDescription
        url = model.url?.absoluteString ?? ""
        urlToImage = model.urlToImage?.absoluteString
        publishedAt = model.publishedAt
        content = model.content
    }
    
    
}

// MARK: - News Network Object
struct NewsModel: Codable {
    let status: String
    let totalResults: Int
    let articles: [ArticleModel]
    
    static var emptyNews = NewsModel(status: "", totalResults: 0, articles: [])
}

// MARK: - Article Network Object
struct ArticleModel: Codable {
    let source: Source
    let author: String?
    let title, articleDescription: String
    let url: URL?
    let urlToImage: URL?
    let publishedAt: Date
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source Network Object
struct Source: Codable {
    let id: String
    let name: String
}
