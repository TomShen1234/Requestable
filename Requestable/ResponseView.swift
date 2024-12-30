//
//  ResponseView.swift
//  Requestable
//
//  Created by Tom Shen on 2024/12/26.
//

import SwiftUI

struct ResponseView: View {
    @EnvironmentObject private var requestManager: RequestManager
    
    // Only used for display purposes
    var requestData: RequestableData
    
    @State private var currentStateURL: String?
    
    var body: some View {
        Group {
            #if os(macOS)
            macView
            #elseif os(iOS)
            iosView
            #endif
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
    }
    
    #if os(iOS)
    var iosView: some View {
        Text("TODO")
    }
    #elseif os(macOS)
    var macView: some View {
        VStack(alignment: .leading) {
            requestStatusView
                .bold()
                .font(.title2)
            
            httpStatusView
            
            Divider()
            
            GeometryReader { geometry in
                ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            httpHeaderContent
                                .textSelection(.enabled)
                                .font(.custom("Menlo Regular", size: 13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                        }
                        .frame(width: geometry.size.width)
                    }
            }
            .frame(maxHeight: 150)
            
            Divider()
            
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        httpResponseContent
                            .textSelection(.enabled)
                            .font(.custom("Menlo Regular", size: 13))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .frame(width: geometry.size.width)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.colorInvert())
    }
    #endif
    
    private var requestStatusView: some View {
        Group {
            if requestManager.state == .finished {
                Text("\(requestData.requestMethod.description) \(currentStateURL ?? "?")")
            } else {
                Text("\(requestManager.state)")
            }
        }
        .onChange(of: requestManager.state) { _, newValue in
            // Only update URL on this page if a new request's made
            if newValue == .finished {
                print("Finished")
                currentStateURL = requestData.generateURL()?.absoluteString
            }
        }
    }
    
    private var httpStatusView: some View {
        let statusCode = requestManager.response?.statusCode ?? 0
        var message = "\(statusCode)"
        if let messageText = HTTPStatusCodeMessage[statusCode] {
            message += " - \(messageText)"
        }
        return Text(message)
            .opacity(requestManager.state == .idle ? 0 : 1)
    }
    
    private var httpHeaderContent: some View {
        Text(requestManager.responseHeader)
    }
    
    private var httpResponseContent: some View {
        if let responseData = requestManager.responseData {
            Text(String(decoding: responseData, as: UTF8.self))
        } else {
            Text("")
        }
    }
}

#Preview {
    ResponseView(requestData: .init())
}
