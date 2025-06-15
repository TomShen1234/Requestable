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

struct BasicAuthorizationSheet: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Binding var modifyingDictionary: [String: String]
    
    var body: some View {
        VStack {
            Text("Edit Basic Authorization")
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    let newPassString = "\(username):\(password)"
                    if let data = newPassString.data(using: .utf8) {
                        let base64String = data.base64EncodedString()
                        modifyingDictionary["Authorization"] = "Basic \(base64String)"
                    }
                    dismiss()
                }
                .disabled(username.isEmpty)
            }
            Text("Note: This information is stored as plain text")
                .font(.caption)
        }
        .padding()
        .onAppear {
            guard var authorizationHeader = modifyingDictionary["Authorization"] else { return }
            // Remove the 'Basic ' text
            let suffixStartIndex = authorizationHeader.index(authorizationHeader.startIndex, offsetBy: 6)
            authorizationHeader = String(authorizationHeader.suffix(from: suffixStartIndex))
            guard let decodedAuthData = Data(base64Encoded: authorizationHeader) else { return }
            guard let decodedAuth = String(data: decodedAuthData, encoding: .utf8) else { return }
            let authSplit = decodedAuth.split(separator: ":")
            guard authSplit.count == 2 else { return }
            username = String(authSplit[0])
            password = String(authSplit[1])
        }
    }
}

#Preview {
    SimpleInputSheets(title: "Input Preview", modifyingText: .constant("Test"))
}
