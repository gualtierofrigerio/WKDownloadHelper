//
//  WKDownloadHelper+types.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//
import Foundation

/// Struct representing a MIME type
///
/// A MIME type is composed of a string describing the type
/// and a file extension expected for it
/// ```
/// MimeType(type: "pdf", fileExtension: "pdf")
/// ```
public struct MimeType {
    /// string representing the MIME type
    var type:String
    /// string with the file extension associated with the type
    var fileExtension:String
    
    /// Initialise the struct with the type and the file extension
    /// - Parameters:
    ///   - type: string representing the MIME type
    ///   - fileExtension: string with the file extension associated with the type
    public init(type: String, fileExtension: String) {
        self.type = type
        self.fileExtension = fileExtension
    }
}
