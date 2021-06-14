//
//  ContentView.swift
//  Shared
//
//  Created by Tom Shen on 2021/6/14.
//

import SwiftUI

// TODO: iOS View
struct ContentView: View {
    @Binding var fileData: RequestableData
    
    @State var test: String = ""

    var body: some View {
        #if os(macOS)
        HSplitView {
            RequestView(requestData: $fileData)

            Text("Second")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #else
        Text("iOS Content View")
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fileData: .constant(.init()))
    }
}
