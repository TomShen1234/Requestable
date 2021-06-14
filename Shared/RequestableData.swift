//
//  RequestableData.swift
//  Requestable
//
//  Created by Tom Shen on 2021/6/14.
//

import Foundation

struct RequestableData: Codable {
    var domain: String
    
    init() {
        domain = ""
    }
}
