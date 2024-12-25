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
            case .get: return "GET"
            case .post: return "POST"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .delete: return "DELETE"
            }
        }
    }
    
    enum BodyEncodingMethod: Codable, CaseIterable, CustomStringConvertible {
        case json, urlEncodedForm
        
        // Description for this is used only for user-facing display
        var description: String {
            switch self {
            case .json: return "JSON"
            case .urlEncodedForm: return "URL Encoded Form"
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
    
    var tokens: [String: String]
    
    var bodyParameters: [String: String]
    
    init() {
        requestProtocol = .http
        domain = ""
        path = ""
        requestMethod = .get
        
        useCustomBody = false
        customBody = ""
        
        tokens = [:]
        
        bodyParameters = [:]
    }
    
    private func stringPathComponents(from path: String) -> [String] {
        return path.split(separator: "/").map(String.init)
    }
    
    private func tokenPathComponents(from path: String) -> [String] {
        return stringPathComponents(from: path).filter { $0.starts(with: ":") }.map { component in
            // Remove the first : from the string
            var mutable = component
            mutable.remove(at: mutable.startIndex)
            return mutable
        }
    }
    
    mutating func updateTokens(from newPath: String) {
        // Logic for tokens:
        // 1. If there's a new token, add it to the list
        // 2. If a token is removed, only remove it if it's empty
        let tokenComponents = tokenPathComponents(from: newPath)
        for tokenName in tokenComponents {
            if tokenName.isEmpty {
                // Ignores empty token
                continue
            }
            if !tokens.keys.contains(tokenName) {
                // Existing token list does not have a token with key, add one
                tokens[tokenName] = ""
            }
        }
        // Remove extraneous tokens in the list
        tokens.keys.forEach { tokenName in
            if !tokenComponents.contains(tokenName) && tokens[tokenName]?.isEmpty ?? false {
                tokens[tokenName] = nil
            }
        }
    }
    
    func generateURL() -> URL? {
        // Process path components
        var pathComponents = stringPathComponents(from: path)
        for token in tokens {
            let tokenPathComponent = ":\(token.key)"
            // Replace token path component with their values
            if let index = pathComponents.firstIndex(of: tokenPathComponent) {
                pathComponents[index] = token.value
            }
        }
        // Remove empty path components
        let path = pathComponents.filter({ !$0.isEmpty }).joined(separator: "/")
        let domainWithProtocol = requestProtocol.description + "://" + domain + "/"
        var urlComponents = URLComponents(string: domainWithProtocol)
        urlComponents?.path = "/\(path)"
        return urlComponents?.url
    }
}
