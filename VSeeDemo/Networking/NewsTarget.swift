//
//  NewsTarget.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import Foundation
import Moya

private let apiKey = "6ba4edd8185c4d27966fc76393bdd1ed"
private let sources = "bbc-sport"

enum NewsTarget {
    case fetchTopHeadlines
    case fetchNews(before: Date)
}

extension NewsTarget: TargetType {
    
    var baseURL: URL { return URL(string: "https://newsapi.org/v2")! }
    
    var path: String {
        switch self {
        case .fetchTopHeadlines:
            return "/top-headlines"
        case .fetchNews(_):
            return "/everything"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchTopHeadlines, .fetchNews:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchTopHeadlines:
            return .requestParameters(parameters: ["apiKey":apiKey, "sources": sources], encoding: JSONEncoding.default)
        case .fetchNews(before: let date):
            let formatted = date.toString("yyyy-MM-dd'T'HH:mm:ssZ")
            return .requestParameters(parameters: ["apiKey":apiKey, "sources": sources, "to": formatted], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchTopHeadlines, .fetchNews:
            guard let url = Bundle.main.url(forResource: "StubData", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

