//
//  RequestableData.swift
//  Requestable
//
//  Created by Tom Shen on 2021/6/14.
//

import Foundation

struct RequestableData: Codable {
    enum RequestProtocol: Codable, CaseIterable, CustomStringConvertible {
        case http, https
        
        var description: String {
            switch self {
            case .http: return "http"
            case .https: return "https"
            }
        }
    }
    
    enum RequestMethod: Codable, CaseIterable, CustomStringConvertible {
        case post, get, put, patch, delete
        
        var description: String {
            switch self {
            case .post: return "POST"
            case .get: return "GET"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .delete: return "DELETE"
            }
        }
    }
    
    var requestProtocol: RequestProtocol
    var domain: String
    var path: String
    var requestMethod: RequestMethod
    
    var generatedBody: String {
        return "TODO: Generated Body"
    }
    var useCustomBody: Bool {
        didSet {
            customBody = useCustomBody ? generatedBody : ""
        }
    }
    var customBody: String
    
    init() {
        requestProtocol = .http
        domain = ""
        path = ""
        requestMethod = .post
        
        useCustomBody = false
        customBody = ""
    }
}
