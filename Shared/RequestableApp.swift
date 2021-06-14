//
//  RequestableApp.swift
//  Shared
//
//  Created by Tom Shen on 2021/6/14.
//

import SwiftUI

@main
struct RequestableApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: RequestableDocument()) { file in
            ContentView(fileData: file.$document.fileData.fileContent)
        }
    }
}
