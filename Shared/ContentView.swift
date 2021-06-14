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

    var body: some View {
        HSplitView {
            RequestView(requestData: $fileData)
            
            Text("Second")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fileData: .constant(.init()))
    }
}
