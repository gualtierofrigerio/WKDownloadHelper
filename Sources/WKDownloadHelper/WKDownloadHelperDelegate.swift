//
//  WKDownloadHelperDelegate.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//

import Foundation

public protocol WKDownloadHelperDelegate {
    func canNavigate(toUrl: URL) -> Bool // optional
    func didDownloadFile(atUrl: URL) // required
    func didFailDownloadingFile(error: Error) // optional
}

/// default implementation of optional methods
extension WKDownloadHelperDelegate {
    func canNavigate(toUrl: URL) -> Bool {
        true
    }
    
    func didFailDownloadingFile(error: Error) {
        
    }
}
