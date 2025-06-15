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
    
    @EnvironmentObject private var requestManager: RequestManager
    
    @State private var editTokenKey = ""
    @State private var showTokenEditor = false
    
    @State private var editHeaderParamKey = ""
    @State private var showHeaderParamEditor = false
    
    @State private var editAuthorization = false
    
    @State private var editBodyParamKey = ""
    @State private var showBodyParamEditor = false
    
    @State private var cannotPerformRequest = false
    
    var body: some View {
        Group {
            #if os(macOS)
            macView
            #elseif os(iOS)
            iosView
            #endif
        }
        .sheet(isPresented: $showTokenEditor) {
            SimpleInputSheets(title: "Edit token: \(editTokenKey)", modifyingText: $requestData.tokens[editTokenKey])
        }
        .sheet(isPresented: $showHeaderParamEditor) {
            KeyValueSheet(modifyKey: editHeaderParamKey, modifyingDictionary: $requestData.headers)
        }
        .sheet(isPresented: $showBodyParamEditor) {
            KeyValueSheet(modifyKey: editBodyParamKey, modifyingDictionary: $requestData.bodyParameters)
        }
        .sheet(isPresented: $editAuthorization) {
            BasicAuthorizationSheet(modifyingDictionary: $requestData.headers)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    // For now, only GET parameter will support query parameters
                    let useQueryParameter = requestData.requestMethod == .get
                    if let url = requestData.generateURL(includesQueryParams: useQueryParameter) {
                        requestManager.performRequest(with: url, method: requestData.requestMethod, headers: requestData.headers, body: requestData.generatedBody)
                    } else {
                        cannotPerformRequest = true
                    }
                } label: {
                    Label {
                        Text("Run Request")
                    } icon: {
                        Image(systemName: "play.fill")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Run the URL request (⌘R)")
            }
        }
        .alert("Cannot perform request due to invalid URL", isPresented: $cannotPerformRequest) {}
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

                pathTextField
                    .frame(minWidth: 140)
                    .onChange(of: requestData.path) { _, newValue in
                        requestData.updateTokens(from: newValue)
                    }
                
                methodPicker
                    .labelsHidden()
                    .frame(width: 80)
            }

            GroupBox("URL Path Tokens") {
                Group {
                    if requestData.tokens.isEmpty {
                        Text("Prefix path component with colon (:) to use tokens")
                    } else {
                        List {
                            pathTokenList
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 75)
            }

            fullURLPreview
                .textSelection(.enabled)

            Divider()

            GroupBox("URL Header") {
                Group {
                    if requestData.headers.isEmpty {
                        Text("HTTP Headers")
                    } else {
                        List {
                            headerParameterList
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 75)
            }
            .overlay(HStack {
                authenticationButton
                addHeaderParameterButton
            }, alignment: .topTrailing)

            Divider()

            GroupBox("HTTP Body / Query Parameters") {
                Group {
                    if requestData.bodyParameters.isEmpty {
                        Text("HTTP Body Parameters")
                    } else {
                        List {
                            bodyParameterList
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 75)
            }
            .overlay(addBodyParameterButton, alignment: .topTrailing)

            customBodyToggle
            bodyTextEditor
                .padding(2)
                .border(.separator)
        }
        .padding()
        .frame(minWidth: 440, idealWidth: 460, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
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
    
    private var pathTokenList: some View {
        DictionaryForEachListContent(dictionary: $requestData.tokens, immutable: true) { clickedTokenKey in
            editTokenKey = clickedTokenKey
            showTokenEditor = true
        }
    }
    
    private var fullURLPreview: some View {
        Text(requestData.generateURL()?.absoluteString ?? "Invalid URL")
    }
    
    private var authenticationButton: some View {
        Button("Authentication") {
            editAuthorization = true
        }
        #if os(macOS)
        .controlSize(.mini)
        #endif
    }
    
    private var addHeaderParameterButton: some View {
        Button("+") {
            editHeaderParamKey = ""
            showHeaderParamEditor = true
        }
        #if os(macOS)
        .controlSize(.mini)
        #endif
    }
    
    private var headerParameterList: some View {
        DictionaryForEachListContent(dictionary: $requestData.headers) { clickedParamKey in
            editHeaderParamKey = clickedParamKey
            showHeaderParamEditor = true
        }
    }
    
    private var addBodyParameterButton: some View {
        Button("+") {
            editBodyParamKey = ""
            showBodyParamEditor = true
        }
        #if os(macOS)
        .controlSize(.mini)
        #endif
    }
    
    private var bodyParameterList: some View {
        DictionaryForEachListContent(dictionary: $requestData.bodyParameters) { clickedParamKey in
            editBodyParamKey = clickedParamKey
            showBodyParamEditor = true
        }
    }
    
    private var customBodyToggle: some View {
        Toggle("Custom HTTP Body", isOn: $requestData.useCustomBody)
            .disabled(true) // TODO: Enable this
    }
    
    private var bodyTextEditor: some View {
        TextEditor(text: requestData.useCustomBody ? $requestData.customBody : .constant(requestData.generatedBody))
            .font(.custom("Menlo Regular", size: 13, relativeTo: .body))
//            .disabled(!requestData.useCustomBody)
    }
}

#Preview {
    #if os(iOS)
    NavigationView {
        RequestView(requestData: .constant(.init()))
            .navigationTitle("Request Preview")
            .navigationBarTitleDisplayMode(.inline)
    }
    #elseif os(macOS)
    RequestView(requestData: .constant(.init()))
    #endif
}
