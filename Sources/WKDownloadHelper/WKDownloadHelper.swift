//
//  WKDownloadHelper.swift
//  WKDownloadHelper
//
//  Created by Gualtiero Frigerio on 12/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//

import Foundation
import WebKit

@available(iOS 11.0, *)
public class WKDownloadHelper: NSObject {
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
    
    internal func downloadData(fromURL url:URL,
                              fileName:String,
                              completion:@escaping (Bool, URL?) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
            let session = URLSession.shared
            session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
            let task = session.downloadTask(with: url) { localURL, urlResponse, error in
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
    
    internal func getDefaultFileName(forMimeType mimeType:String) -> String {
        for record in mimeTypes {
            if mimeType.contains(record.type) {
                return "default." + record.fileExtension
            }
        }
        return "default"
    }
    
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
    
    internal func isMimeTypeConfigured(_ mimeType:String) -> Bool {
        for record in mimeTypes {
            if mimeType.contains(record.type) {
                return true
            }
        }
        return false
    }
    
    internal func moveDownloadedFile(url:URL, fileName:String) -> URL {
        let tempDir = NSTemporaryDirectory()
        let destinationPath = tempDir + fileName
        let destinationURL = URL(fileURLWithPath: destinationPath)
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.moveItem(at: url, to: destinationURL)
        return destinationURL
    }
}
