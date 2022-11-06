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
}
