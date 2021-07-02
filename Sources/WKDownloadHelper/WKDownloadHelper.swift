//
//  WKDownloadHelper.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//

import Foundation
import WebKit


/// Takes care of downloading file with a WKWebview
///
/// The object becomes the navigation delegate of the WKWebView and has to be configured with supported MIME types and a ``WKDownloadHelperDelegate`` object to receive updated about file downloads.
@available(iOS 11.0, *)
public class WKDownloadHelper: NSObject {
    /// Initialize the helper with a webview, supported MIME types and the delegate object
    ///
    /// WKDownloadHelper doesn't take care of placing the webview on screen, it only acts as a delegate
    /// and interacts with its configuration property. It is the caller responsibility to
    /// present the webview and eventually dismiss it when it is no more necessary.
    /// - Parameters:
    ///   - webView: the WKWebView necessary to download files
    ///   - supportedMimeTypes: an array of ``MimeType`` supported.
    ///   - delegate: the ``WKDownloadHelperDelegate`` object
    public init(webView: WKWebView,
         supportedMimeTypes: [MimeType],
         delegate: WKDownloadHelperDelegate) {
        self.webView = webView
        self.delegate = delegate
        self.mimeTypes = supportedMimeTypes
        super.init()
        webView.navigationDelegate = self
    }
    
    // MARK: - Private
    
    private var webView: WKWebView
    internal var delegate: WKDownloadHelperDelegate?
    internal var fileDestinationURL: URL?
    internal var mimeTypes: [MimeType] = []
    
    /// Download data from a specific url and call a completion handler once done
    /// - Parameters:
    ///   - url: the URL of the file to download
    ///   - fileName: name of the file where data will be stored on the file system
    ///   - completion: completion handler with a Bool parameter indicating success and the optional URL of the downloaded file
    internal func downloadData(fromURL url:URL,
                              fileName:String,
                              completion:@escaping (Bool, URL?) -> Void) {
        let downloadURL = removeBlob(fromUrl: url)
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
            let session = URLSession.shared
            session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
            let task = session.downloadTask(with: downloadURL) { localURL, urlResponse, error in
                if let localURL = localURL {
                    let destinationURL = self.moveDownloadedFile(url: localURL, fileName: fileName)
                    completion(true, destinationURL)
                }
                else {
                    completion(false, nil)
                }
            }

            task.resume()
        }
    }
    
    /// Returns the default file name for a specific  MIME type.
    ///
    /// This is necessary if the file name cannot be determined by the response so we can have a file name
    /// to save the downloaded data to the filesystem
    /// - Parameter mimeType: string representing the MIME type
    /// - Returns: a string with the file name
    internal func getDefaultFileName(forMimeType mimeType:String) -> String {
        for record in mimeTypes {
            if mimeType.contains(record.type) {
                return "default." + record.fileExtension
            }
        }
        return "default"
    }
    
    /// Tries to determine the name of the file from the ``URLResponse``
    ///
    /// This function tries to retrieve the name of the file to download from the Content-Disposition header
    /// and returns the name if it is able to find it.
    ///
    /// - Parameter response: the URLResponse of the file we have to download
    /// - Returns: an optional string with the file name if found
    internal func getFileNameFromResponse(_ response:URLResponse) -> String? {
        if let httpResponse = response as? HTTPURLResponse {
            let headers = httpResponse.allHeaderFields
            if let disposition = headers["Content-Disposition"] as? String {
                let components = disposition.components(separatedBy: " ")
                if components.count > 1 {
                    let innerComponents = components[1].components(separatedBy: "=")
                    if innerComponents.count > 1 {
                        if innerComponents[0].contains("filename") {
                            return innerComponents[1]
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Check if the MIME type is within the configured ones
    /// - Parameter mimeType: string representing the MIME type
    /// - Returns: true if the type is configured
    internal func isMimeTypeConfigured(_ mimeType:String) -> Bool {
        for record in mimeTypes {
            if mimeType.contains(record.type) {
                return true
            }
        }
        return false
    }
    
    /// Move the dowloaded file from the temporary location returned by ``URLSession`` to a local path
    /// - Parameters:
    ///   - url: the ``URL`` of the downloaded file
    ///   - fileName: string representing the name of the destination file
    /// - Returns: destination ``URL`` of the moved file
    internal func moveDownloadedFile(url:URL, fileName:String) -> URL {
        let tempDir = NSTemporaryDirectory()
        let destinationPath = tempDir + fileName
        let destinationURL = URL(fileURLWithPath: destinationPath)
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.moveItem(at: url, to: destinationURL)
        return destinationURL
    }
    
    /// Remove blob in front of an URL
    /// - Parameter fromUrl: The url from where blob has to be removed
    /// - Returns: A URL without blob
    internal func removeBlob(fromUrl: URL) -> URL {
        let downloadURLString = fromUrl.absoluteString
        if downloadURLString.starts(with: "blob:") {
            return URL(string: String(downloadURLString.dropFirst(5)))!
        }
        else {
            return fromUrl
        }
    }
}
