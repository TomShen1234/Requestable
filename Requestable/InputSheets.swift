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

struct KeyValueSheet: View {
    @State private var localKey: String = ""
    @State private var localValue: String = ""
    
    @Environment(\.dismiss) private var dismiss
    var modifyKey: String
    @Binding var modifyingDictionary: [String: String]
    
    var body: some View {
        VStack {
            TextField("Key", text: $localKey)
            TextField("Value", text: $localValue)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    if localKey != modifyKey {
                        // Key changed, remove old value
                        modifyingDictionary[modifyKey] = nil
                    }
                    modifyingDictionary[localKey] = localValue
                    dismiss()
                }
                .disabled(localKey.isEmpty)
            }
        }
        .padding()
        .onAppear {
            localKey = modifyKey
            localValue = modifyingDictionary[modifyKey] ?? ""
        }
    }
}

#Preview {
    SimpleInputSheets(title: "Input Preview", modifyingText: .constant("Test"))
}
