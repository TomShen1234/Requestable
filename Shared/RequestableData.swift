//
//  RequestableData.swift
//  Requestable
//
//  Created by Tom Shen on 2021/6/14.
//

import Foundation

struct RequestableData: Codable {
    enum RequestProtocol: Codable, CaseIterable {
        case http, https
        
        func displayText() -> String {
            switch self {
            case .http:
                return "http"
            case .https:
                return "https"
            }
        }
    }
    
    var requestProtocol: RequestProtocol
    var domain: String
    var path: String
    
    init() {
        requestProtocol = .http
        domain = ""
        path = ""
    }
}
