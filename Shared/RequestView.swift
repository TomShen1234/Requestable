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
        #if os(macOS)
        macView
        #elseif os(iOS)
        iosView
        #endif
    }
    
    #if os(iOS)
    var iosView: some View {
        Form {
            Section("Request URL") {
                protocolPicker
                domainTextField
                pathTextField
                methodPicker
            }
            
            Section {
                Text("TODO")
            } header: {
                Text("URL Path Tokens")
            } footer: {
                Text("Prefix path component with colon (:) to use tokens")
            }
            
            Section("URL Header") {
                Text("Table with header informations")
            }
            
            Section("HTTP Body") {
                Text("HTTP Body Parameters")
            }
            
            Section("HTTP Body Content") {
                customBodyToggle
                bodyTextEditor.frame(height: 100)
            }
        }
    }
    #elseif os(macOS)
    var macView: some View {
        VStack(alignment: .leading) {
            HStack {
                protocolPicker
                    .labelsHidden()
                    .frame(width: 65)

                domainTextField.frame(minWidth: 100)

                pathTextField.frame(minWidth: 140)
                
                methodPicker
                    .labelsHidden()
                    .frame(width: 80)
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
            .overlay(authenticationButton.controlSize(.mini), alignment: .topTrailing)

            Divider()

            GroupBox("HTTP Body") {
                VStack {
                    Text("HTTP Body Parameters")
                        .frame(maxWidth: .infinity, minHeight: 75)
                }
            }

            customBodyToggle
            bodyTextEditor
                .padding(2)
                .border(.separator)
        }
        .padding()
        .frame(minWidth: 440, minHeight: 500)
        .background(Color.primary.colorInvert())
    }
    #endif
    
    private var protocolPicker: some View {
        Picker("Select Protocol", selection: $requestData.requestProtocol) {
            ForEach(RequestableData.RequestProtocol.allCases, id: \.self) { reqProtocol in
                Text("\(reqProtocol.description)")
            }
        }
    }
    
    private var methodPicker: some View {
        Picker("Select Method", selection: $requestData.requestMethod) {
            ForEach(RequestableData.RequestMethod.allCases, id: \.self) { method in
                Text("\(method.description)")
            }
        }
    }
    
    private var domainTextField: some View {
        TextField("Domain/IP", text: $requestData.domain)
//        #if os(iOS) // TODO: Enable once preview is fixed
//            .textContentType(.URL)
//            .keyboardType(.URL)
//        #endif
    }
    
    private var pathTextField: some View {
        TextField("Path to Resource (/)", text: $requestData.path)
//        #if os(iOS) // TODO: Enable once preview is fixed
//            .textContentType(.URL)
//            .keyboardType(.URL)
//        #endif
    }
    
    private var fullURLPreview: some View {
        Text("(Full URL goes here)")
    }
    
    private var authenticationButton: some View {
        Button("Authentication") {
            print("Show authentication sheet")
        }
//        #if os(macOS) // TODO: Enable once preview is fixed
//        .controlSize(.mini)
//        #endif
    }
    
    private var customBodyToggle: some View {
        Toggle("Custom HTTP Body", isOn: $requestData.useCustomBody)
    }
    
    private var bodyTextEditor: some View {
        TextEditor(text: requestData.useCustomBody ? $requestData.customBody : .constant(requestData.generatedBody))
            .font(.custom("Menlo Regular", size: 13, relativeTo: .body))
            .disabled(!requestData.useCustomBody)
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            RequestView(requestData: .constant(.init()))
                .navigationTitle("Request Preview")
                .navigationBarTitleDisplayMode(.inline)
        }
        #elseif os(macOS)
        RequestView(requestData: .constant(.init()))
            .previewLayout(.fixed(width: 440, height: 600))
        #endif
    }
}
