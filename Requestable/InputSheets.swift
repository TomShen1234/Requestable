//
//  InputSheets.swift
//  Requestable
//
//  Created by Tom Shen on 2024/12/25.
//

import SwiftUI

struct SimpleInputSheets: View {
    @State private var localText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var title: String = "Input"
    @Binding var modifyingText: String?
    
    var body: some View {
        VStack {
            Text(title)
            TextField("Editing \(title)", text: $localText)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    modifyingText = localText
                    dismiss()
                }
            }
        }
        .padding()
        .onAppear {
            localText = modifyingText ?? ""
        }
    }
}

#Preview {
    SimpleInputSheets(title: "Input Preview", modifyingText: .constant("Test"))
}
