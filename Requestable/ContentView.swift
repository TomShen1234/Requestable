//
//  ContentView.swift
//  Requestable
//
//  Created by Tom Shen on 2023/06/18.
//

import SwiftUI

struct ContentView: View {
    @Binding var fileData: RequestableData

    var body: some View {
        #if os(macOS)
        // TODO: Split View
        RequestView(requestData: $fileData)
        #elseif os(iOS)
        RequestView(requestData: $fileData)
        #endif
    }
}

#Preview {
    ContentView(fileData: .constant(.init()))
}
