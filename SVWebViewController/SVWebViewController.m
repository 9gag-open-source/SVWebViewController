//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewControllerActivityChrome.h"
#import "SVWebViewControllerActivitySafari.h"
#import "SVWebViewController.h"
#import "UIApplication+TopMostViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface SVWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *activityIndicatorItem;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (void)loadURL:(NSURL*)URL;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation SVWebViewController

#pragma mark - Initialization

- (void)dealloc {
    [self.webView stopLoading];
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.delegate = nil;
}

- (id)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithLocalAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL fileURLWithPath:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    self = [self init];
    self.URL = pageURL;
    return self;
}

- (id)init {
    if(self = [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
        self.hideProgress = NO;
        self.hideControls = NO;
        self.hideTitle = NO;
        self.hideBottomToolbar = NO;
    }
    return self;
}

- (void)loadURL:(NSURL *)pageURL {
    [self.webView loadRequest:[NSURLRequest requestWithURL:pageURL]];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    [self loadURL:URL];
}

#pragma mark - View lifecycle

- (void)loadView {
    self.view = self.webView;
//    [self loadURL:self.URL];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self updateToolbarItems];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _actionBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
	
    if (!self.hideBottomToolbar && !self.hideControls && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @" ";
    self.navigationItem.backBarButtonItem = backButton;
    
    if(!self.hideProgress){
        
        _progressProxy = [[NJKWebViewProgress alloc] init];
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.navigationController.navigationBar addSubview:_progressView];
        
        [_progressView setProgress:0.0f];
        
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        
    } else {
        _webView.delegate = self;
    }
    
}
- (void)popNavigationController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (_progressView) {
        [_progressView removeFromSuperview];
        _progressProxy.webViewProxyDelegate = nil;
        _progressProxy.progressDelegate = nil;
    }
    _webView.delegate = nil;
    
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        return YES;
//    
//    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
//}

#pragma mark - Getters

- (UIWebView*)webView {
    if(!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"svwebview-btn-arrow-left"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
//		_backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"svwebview-btn-arrow-right"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
//		_forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"svwebview-nav-reload"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadClicked:)];
    }
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    if (!_stopBarButtonItem) {
        _stopBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"svwebview-btn-stop"] style:UIBarButtonItemStylePlain target:self action:@selector(stopClicked:)];
    }
    return _stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"svwebview-overlay-btn-share"] style:UIBarButtonItemStylePlain target:self action:@selector(actionButtonClicked:)];
    }
    return _actionBarButtonItem;
}

- (UIBarButtonItem *)activityIndicatorItem {
    if (!_activityIndicatorItem) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(0, 0, 25, 25);
        [activityView sizeToFit];
        [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
        _activityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
        
    }
    return _activityIndicatorItem;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    
    if(self.hideControls) return;
    
    self.backBarButtonItem.enabled = self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.webView.canGoForward;
//    self.actionBarButtonItem.enabled = !self.webView.isLoading;
    
    (self.webView.isLoading || !self.URL)? [((UIActivityIndicatorView *)self.activityIndicatorItem.customView) startAnimating] : [((UIActivityIndicatorView *)self.activityIndicatorItem.customView) stopAnimating];
    
    BOOL isHTTP = [self.webView.request.URL.scheme isEqualToString:@"http"] || [self.webView.request.URL.scheme isEqualToString:@"https"];
    _progressView.alpha = isHTTP? 1.0 : 0.0;

    [self createToolbarItems];
    
}

- (void)createToolbarItems {
    
    UIBarButtonItem *refreshStopBarButtonItem = (self.webView.isLoading || !self.URL) ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        CGFloat toolbarWidth = 44.0f;
        fixedSpace.width = 35.0f;
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.activityIndicatorItem,
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,
                          fixedSpace,
                          self.actionBarButtonItem,
                          nil];
        
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else {
        
        //        fixedSpace.width = 20;
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.backBarButtonItem,
                          flexibleSpace,
                          self.forwardBarButtonItem,
                          flexibleSpace,
                          refreshStopBarButtonItem,
                          flexibleSpace,
                          self.actionBarButtonItem,
                          fixedSpace,
                          nil];
        
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.barTintColor = self.navigationController.navigationBar.barTintColor;
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationController.toolbar.barTintColor = self.navigationController.navigationBar.barTintColor;
        self.toolbarItems = items;
        
        self.navigationItem.rightBarButtonItem = self.activityIndicatorItem;
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    if(!self.hideTitle){
        self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
    if(self.delegate && [self.delegate respondsToSelector:@selector(webViewController:webViewDidStartLoad:)]){
        [self.delegate webViewController:self webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if(!self.hideTitle){
        self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    [self updateToolbarItems];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(webViewController:webViewDidFinishLoad:)]){
        [self.delegate webViewController:self webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(webViewController:webView:didFailLoadWithError:)]){
        [self.delegate webViewController:self webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(self.delegate && [self.delegate respondsToSelector:@selector(webViewController:webViewShouldStartLoad:withRequest:navigationType:)]){
        return [self.delegate webViewController:self webViewShouldStartLoad:webView withRequest:request navigationType:navigationType];
    }
    return YES;
}

#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [self.webView stopLoading];
	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    if (self.shareDelegate) {
        
        NSString *expectedTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSURL *expectedURL = self.webView.request.URL;
        
        if(!expectedTitle || [expectedTitle isEqualToString:@""]){
            expectedTitle = self.URL.absoluteString;
        }
        if(!expectedURL.absoluteString || [expectedURL.absoluteString isEqualToString:@""]){
            expectedURL = self.URL;
        }
        [self.shareDelegate shareURL:expectedURL withTitle:expectedTitle fromViewController:self];
    } else {
        NSArray *activities = @[[SVWebViewControllerActivitySafari new], [SVWebViewControllerActivityChrome new]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.request.URL] applicationActivities:activities];
        [[UIApplication topMostViewController] presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
