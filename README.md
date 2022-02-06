# WKDownloadHelper

Download files from a WKWebView

See [WKWebViewDownloadHelper](https://github.com/gualtierofrigerio/WKWebViewDownloadHelper) for examples on how to use this package or refer to my blog post [Download files in a WKWebView](http://www.gfrigerio.com/download-files-in-a-wkwebview/)

The DocC archive with this framework documentation is also available to be imported in Xcode

## How it works

Create a instante of WKDownloadHelper with a WKWebView, a list of MIME types you want to support and a delegate. You'll be able to chose the path of the downloaded file, be notified about errors or the successful download operation.

```swift
import WKDownloadHelper

override func viewDidLoad() {
    super.viewDidLoad()
    
    let webView = WKWebView(frame: self.view.frame)
    self.view.addSubview(webView)
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let mimeTypes = [MimeType(type: "ms-excel", fileExtension: "xls"),
                     MimeType(type: "pdf", fileExtension: "pdf")]
    downloadHelper = WKDownloadHelper(webView: webView,
                                      supportedMimeTypes: mimeTypes,
                                      delegate: self)
    let request = URLRequest(url: URL(string: "https://www.google.it")!)
    webView.load(request)
    self.webView = webView
}
```

Once you downloaded a file you can open a UIActivityViewController to open it with another app like this 

```swift
extension ViewController: WKDownloadHelperDelegate {
    func didFailDownloadingFile(error: Error) {
        print("error while downloading file \(error)")
    }
    
    func didDownloadFile(atUrl: URL) {
        print("did download file!")
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: [atUrl], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = self.view.frame
            activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
```

or you can open it inside your app with QLPreviewController.


## Install

The package is distributed via SPM. Include the link below in Xcode to add it to your project.
```
https://github.com/gualtierofrigerio/WKDownloadHelper.git
```
