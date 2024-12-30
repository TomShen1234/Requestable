//
//  RequestableApp.swift
//  Requestable
//
//  Created by Tom Shen on 2023/06/18.
//

import SwiftUI

@main
struct RequestableApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: RequestableDocument()) { file in
            ContentView(fileData: file.$document.fileData.data)
        }
    }
}
