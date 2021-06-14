//
//  RequestView.swift
//  Requestable
//
//  Created by Tom Shen on 2021/6/14.
//

import SwiftUI

// TODO: iOS View
struct RequestView: View {
    @Binding var requestData: RequestableData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Select Protocol", selection: $requestData.requestProtocol) {
                    ForEach(RequestableData.RequestProtocol.allCases, id: \.self) { reqProtocol in
                        Text("\(reqProtocol.displayText())")
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .frame(width: 65)
                
                TextField("Domain or IP Address", text: $requestData.domain)
                    .frame(minWidth: 140)
                
                TextField("Path to Resource (/)", text: $requestData.path)
                    .frame(minWidth: 140)
            }
            
            GroupBox("URL Path Tokens") {
                Group {
                    Text("Prefix path component with colon (:) to use tokens")
                }
                .frame(maxWidth: .infinity, minHeight: 75)
            }
            
            Text("(Full URL goes here)")
                .textSelection(.enabled)
            
            Divider()
            
            GroupBox("URL Header") {
                VStack {
                    Text("Table with header informations")
                        .frame(maxWidth: .infinity, minHeight: 75)
                }
            }
            .overlay(authenticationButton, alignment: .topTrailing)
            
            Divider()
            
            GroupBox("HTTP Body") {
                VStack {
                    Text("HTTP Body Parameters")
                        .frame(maxWidth: .infinity, minHeight: 75)
                }
            }
            
            TextEditor(text: .constant("HTTP Body Field"))
                .font(.custom("Menlo Regular", size: 13, relativeTo: .body))
                .padding(2)
                .border(.separator)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
        .background(Color.primary.colorInvert())
    }
    
    private var authenticationButton: some View {
        Button("Authentication") {
            print("Show authentication sheet")
        }
        .controlSize(.mini)
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView(requestData: .constant(.init()))
            .previewLayout(.fixed(width: 400, height: 600))
    }
}
