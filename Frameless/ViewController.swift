//
//  ViewController.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate {


    @IBOutlet weak var _webView: UIWebView!
    @IBOutlet weak var _searchBar: SearchBar!
    @IBOutlet weak var _progressView: UIProgressView!
    
    var _panRecognizer: UIScreenEdgePanGestureRecognizer?
    var _areControlsVisible = true
    
    // Loading progress? Fake it till you make it.
    var _progressTimer: NSTimer?
    var _isWebViewLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _panRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleScreenEdgePan:"))
        _panRecognizer!.edges = UIRectEdge.Bottom
        _panRecognizer?.delegate = self
        self.view.addGestureRecognizer(_panRecognizer!)
        _searchBar.delegate = self
        _searchBar.returnKeyType = UIReturnKeyType.Go
        _searchBar.becomeFirstResponder()
        _webView.scalesPageToFit = true
        _webView.delegate = self
        _progressView.hidden = true
        self.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // UI show/hide
    func handleScreenEdgePan(sender: AnyObject) {
        showSearch()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            if (!_areControlsVisible) {
                showSearch()
            } else {
                hideSearch()
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func hideSearch() {
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, -44)
        }, nil)
        _areControlsVisible = false
    }
    
    func showSearch() {
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }, nil)
        _areControlsVisible = true
        _searchBar.becomeFirstResponder()
    }
    
    
    
    // Web view
    func webViewDidStartLoad(webView: UIWebView) {
        _isWebViewLoading = true
        _progressView.hidden = false
        _progressView.progress = 0
        _progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "progressTimerCallback", userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        _isWebViewLoading = false
    }
    
    func progressTimerCallback() {
        if (!_isWebViewLoading) {
            if (_progressView.progress >= 1) {
                _progressView.hidden = true
                _progressTimer?.invalidate()
            } else {
                _progressView.progress += 0.05
            }
        } else {
            _progressView.progress += 0.02
            if (_progressView.progress >= 0.95) {
                _progressView.progress = 0.95
            }
        }
    }
    
    func loadURL(urlString: String) {
        let addrStr = httpifyString(urlString)
        let addr = NSURL(string: addrStr)
        let req = NSURLRequest(URL: addr!)
        _webView.loadRequest(req)
    }
    
    func httpifyString(str: String) -> String {
        let lcStr:String = (str as NSString).lowercaseString
        if (countElements(lcStr) >= 7) {
            if ((lcStr as NSString).substringToIndex(7) == "http://") {
                return lcStr
            }
        }
        return "http://"+lcStr
    }
    
    
    
    // Search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hideSearch()
        loadURL(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hideSearch()
    }


}

