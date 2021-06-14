//
//  ContentView.swift
//  Shared
//
//  Created by Tom Shen on 2021/6/14.
//

import SwiftUI

struct ContentView: View {
    @Binding var fileData: RequestableData

    var body: some View {
        TextEditor(text: $fileData.domain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fileData: .constant(.init()))
    }
}
