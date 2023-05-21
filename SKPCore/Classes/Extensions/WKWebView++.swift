//
//  WKWebView++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/30/21.
//

import Foundation
import WebKit

public extension WKWebView {
    
    func addCssWhenDocumentEnd(_ cssString: String) {
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        let userScript = WKUserScript(source: jsString,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
    }
    
    func injectCss(_ cssString: String) {
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func addViewPortMeta(at time: WKUserScriptInjectionTime = .atDocumentStart) {
        let jsScript = """
                        var meta = document.createElement('meta');
                        meta.setAttribute('name', 'viewport');
                        meta.setAttribute('content', 'width=device-width, shrink-to-fit=YES');
                        document.head.appendChild(meta);
                        """
        let wkScript = WKUserScript(source: jsScript, injectionTime: time, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(wkScript)
    }
    
    /// Inject một file CSS từ bundle vào DOM khi web đã load
    func injectCSS(named cssFileName: String, bundle: Bundle = .main, at time: WKUserScriptInjectionTime = .atDocumentStart) {
        guard let cssPath = bundle.path(forResource: cssFileName, ofType: "css"),
              let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8) else {
            print("❌ Không tìm thấy file CSS: \(cssFileName).css")
            return
        }
        
        // Escape chuỗi để nhúng vào JavaScript
        let escaped = cssContent
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "'", with: "\\'")
        
        let jsScript = """
               (function() {
                   var style = document.createElement('style');
                   style.type = 'text/css';
                   style.innerHTML = '\(escaped)';
                   document.head.appendChild(style);
                   return true;
               })();
               """
        
        let wkScript = WKUserScript(source: jsScript, injectionTime: time, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(wkScript)
    }
    
    /// Loại bỏ toàn bộ CSS gốc runtime
    func removeAllCSS(at time: WKUserScriptInjectionTime = .atDocumentStart) {
        let jsScript = """
           var links = document.querySelectorAll('link[rel=stylesheet], style');
           for (var i = 0; i < links.length; i++) {
               links[i].parentNode.removeChild(links[i]);
           }
           """
        let wkScript = WKUserScript(source: jsScript, injectionTime: time, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(wkScript)
    }
}
