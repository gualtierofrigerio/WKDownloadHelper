//
//  WKDownloadHelperDelegate.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//

import Foundation

/// Delegate object for ``WKDownloadHelper``
///
/// The delegate receives information about file downloaded by the helper
/// as long as errors during a download. It is also possible to prevent an URL to be opened by implementing ``canNavigate(toUrl:)``. The default implementation always return true
public protocol WKDownloadHelperDelegate {
    /// Optional funtion that is called whenever a new URL is about to be opened
    ///
    /// Implement this function if you want more control over the link opened in the WKWebView
    /// Since the helper become the WKNavigationDelegate you lose control of that aspect and this method
    /// allow you to at least prevent some URL to be opened in your WKWebView
    /// - Parameter toUrl: the URL about to be opened by the web view
    /// - Returns: true if the URL can be opened
    func canNavigate(toUrl: URL) -> Bool
    
    /// Mandatory function, called when a file has been successfully downloaded at the given local URL
    /// - Parameter atUrl: local URL of the downloaded file
    func didDownloadFile(atUrl: URL)
    
    /// Called in case of error while downloading a file
    /// - Parameter error: the Error occurred while downloading the file
    func didFailDownloadingFile(error: Error)
    
    
    /// Provide a local url path where the file will be downloaded
    /// - Returns: An optional url of the file
    func localURLForFile(withName: String) -> URL?
}

/// default implementation of optional methods
extension WKDownloadHelperDelegate {
    public func canNavigate(toUrl: URL) -> Bool {
        true
    }
    
    public func didFailDownloadingFile(error: Error) {
        
    }
    
    /// The default implementation saves the file in the temporary directory
    /// inside a rando UUID directory to avoid conflicts of file names
    public func localURLForFile(withName name: String) -> URL? {
        let temporaryDir = NSTemporaryDirectory()
        var url = URL(fileURLWithPath: temporaryDir)
        url = url.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        }
        catch {
            return nil
        }
        url = url.appendingPathComponent(name)
        return url
    }
}
