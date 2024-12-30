//
//  ContentView.swift
//  Requestable
//
//  Created by Tom Shen on 2023/06/18.
//

import SwiftUI

struct ContentView: View {
    @Binding var fileData: RequestableData
    
    @StateObject private var requestManager = RequestManager()

    var body: some View {
        Group {
            #if os(macOS)
            HSplitView {
                RequestView(requestData: $fileData)
                ResponseView(requestData: fileData)
            }
            #elseif os(iOS)
            RequestView(requestData: $fileData)
            #endif
        }
        .environmentObject(requestManager)
    }
}

#Preview {
    ContentView(fileData: .constant(.init()))
}
