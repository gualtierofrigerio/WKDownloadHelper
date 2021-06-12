//
//  WKDownloadHelper+types.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//
import Foundation

public struct MimeType {
    var type:String
    var fileExtension:String
    
    public init(type: String, fileExtension: String) {
        self.type = type
        self.fileExtension = fileExtension
    }
}
