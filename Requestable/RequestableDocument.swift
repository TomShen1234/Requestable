//
//  RequestableDocument.swift
//  Shared
//
//  Created by Tom Shen on 2021/6/14.
//

/// The document version used by the app
let RequestableDocumentVersion = 1

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var requestableDocument: UTType {
        UTType(importedAs: "com.tomandjerry.requestable-req")
    }
}

struct RequestableDocument: FileDocument {
    enum DocumentError: LocalizedError {
        case incompatibleFileVersion
        
        var errorDescription: String? {
            switch self {
            case .incompatibleFileVersion: return "The version of this file is incompatible!"
            }
        }
    }
    
    var fileData: RequestableFileData

    init() {
        self.fileData = RequestableFileData()
    }

    static var readableContentTypes: [UTType] { [.requestableDocument] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(RequestableFileData.self, from: data)
        
        if decodedData.version > RequestableDocumentVersion {
            throw DocumentError.incompatibleFileVersion
        }
        
        self.fileData = decodedData
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        let data = try encoder.encode(fileData)
        return .init(regularFileWithContents: data)
    }
}

struct RequestableFileData: Codable {
    var version: Int
    var data: RequestableData
    
    /// Initialize with default values
    init() {
        version = RequestableDocumentVersion
        data = RequestableData()
    }
}
