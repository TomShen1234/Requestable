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
    
    var tokens: [String: String]
    
    var headers: [String: String]
    
    var bodyParameters: [String: String]
    
    var generatedBody: String {
        if useCustomBody {
            return customBody
        } else if requestMethod == .get {
            // Encode item as URL encoded form data for display only
            let resultURL = generateURL(includesQueryParams: true)
            return resultURL?.absoluteString ?? "Invalid URL"
        } else {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? jsonEncoder.encode(bodyParameters) {
                return String(decoding: data, as: UTF8.self)
            } else {
                return "Cannot encode body as JSON."
            }
        }
    }
    var useCustomBody: Bool
    var customBody: String
    
    init() {
        requestProtocol = .http
        domain = ""
        path = ""
        requestMethod = .get
        
        useCustomBody = false
        customBody = ""
        
        tokens = [:]
        
        headers = [:]
        bodyParameters = [:]
    }
    
    private func stringPathComponents(from path: String) -> [String] {
        path.split(separator: "/").map(String.init)
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
    
    func generateURL(includesQueryParams: Bool = false) -> URL? {
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
        if self.path.last == "/" {
            // Add the trailing / back if necessary
            urlComponents?.path += "/"
        }
        if includesQueryParams && !bodyParameters.keys.isEmpty {
            urlComponents?.queryItems = bodyParameters.map({ URLQueryItem(name: $0.key, value: $0.value) })
        }
        return urlComponents?.url
    }
}

final class RequestManager: ObservableObject {
    enum State: CustomStringConvertible, Equatable {
        case idle
        case loading
        case finished
        case failed(error: String)
        
        var description: String {
            switch self {
            case .idle: "Waiting for request..."
            case .loading: "Loading..."
            case .finished: "Got Results"
            case .failed(let error): "Error: \(error)"
            }
        }
    }
    
    @Published var state: State = .idle
    
    @Published var response: HTTPURLResponse?
    @Published var responseData: Data?
    @Published var responseDataJSON: Any?
    
    @Published var responseHeader: String = ""
    
    @Published var isResultJSON: Bool = false
    
    func performRequest(with url: URL, method: RequestableData.RequestMethod, headers: [String:String], body: String) {
        state = .loading
        
        Task {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = method.description
                if method != .get {
                    let bodyData = body.data(using: .utf8)!
                    request.httpBody = bodyData
                }
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
                if case .post = method {
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                let (data, response) = try await URLSession.shared.data(for: request)
                await self.success(data: data, response: response as! HTTPURLResponse)
            } catch {
                await self.error(error)
            }
        }
    }
    
    private func makeRequestHeader() {
        if let response {
            // Get a sorted key array
            let sortedKeys = response.allHeaderFields.keys.map(String.init).sorted()
            responseHeader =  sortedKeys.reduce("") { partialResult, key in
                let value = response.allHeaderFields[key] as? String
                return partialResult + "\(key): \(value ?? "")\n"
            } // Strip last newline
            .trimmingCharacters(in: .newlines)
        } else {
            responseHeader = ""
        }
    }
    
    private func checkIfFileIsJSON() {
        if let responseData {
            responseDataJSON = try? JSONSerialization.jsonObject(with: responseData, options: [])
            isResultJSON = responseDataJSON != nil
        }
    }
    
    @MainActor private func success(data: Data, response res: HTTPURLResponse) {
        response = res
        responseData = data
        state = .finished
        makeRequestHeader()
        checkIfFileIsJSON()
    }
    
    @MainActor private func error(_ error: Error) {
        state = .failed(error: error.localizedDescription)
    }
    
    func prettifyJSONResponse() {
        guard let json = responseDataJSON else { return }
        self.responseData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
    }
}
