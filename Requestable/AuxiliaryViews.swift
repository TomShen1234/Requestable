//
//  AuxiliaryViews.swift
//  Requestable
//
//  Created by Tom Shen on 2024/12/26.
//

import SwiftUI

/// A simple helper that displays key-value pairs of a `[String: String]` dictionary
struct DictionaryForEachListContent: View {
    @Binding var dictionary: [String: String]
    var immutable = false
    var onClick: (String) -> Void
    
    private func makeButton(key: String) -> some View {
        Button {
            onClick(key)
        } label: {
            HStack {
                Text(key)
                Spacer()
                let value = dictionary[key]
                Text(value ?? "")
            }
            .contentShape(Rectangle())
        }
    }
    
    var body: some View {
        Group {
            if immutable {
                ForEach(Array(dictionary.keys), id: \.self) { key in
                    makeButton(key: key)
                }
            } else {
                ForEach(Array(dictionary.keys), id: \.self) { key in
                    makeButton(key: key)
                } // Make the list modifiable (for header and body table, etc.)
                .onDelete(perform: delete)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func delete(_ indexSet: IndexSet) {
        let keys = Array(dictionary.keys)
        for index in indexSet {
            dictionary.removeValue(forKey: keys[index])
        }
    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
}
