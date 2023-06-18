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
        RequestView(requestData: $fileData)
    }
}

#Preview {
    ContentView(fileData: .constant(.init()))
}
