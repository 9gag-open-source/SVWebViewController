//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"

@class NJKWebViewProgressView;

@protocol SVWebViewControllerShareDelegate <NSObject>
@required
@optional
-(void)shareURL:(NSURL *)url withTitle:(NSString *)title fromViewController:(UIViewController *)viewController;
@end


@protocol SVWebViewControllerDelegate <NSObject>
@optional
- (void)webViewController:(SVWebViewController *)webViewController webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewController:(SVWebViewController *)webViewController webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewController:(SVWebViewController *)webViewController webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webViewController:(SVWebViewController *)webViewController webViewShouldStartLoad:(UIWebView *)webView withRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end

@interface SVWebViewController : UIViewController



@property(nonatomic, weak) id <SVWebViewControllerDelegate> delegate;
@property(nonatomic, weak) id <SVWebViewControllerShareDelegate> shareDelegate;

@property (nonatomic, readwrite) BOOL hideControls;
@property (nonatomic, readwrite) BOOL hideProgress;
@property (nonatomic, readwrite) BOOL hideTitle;
@property (nonatomic, readwrite) BOOL hideBottomToolbar;

@property (nonatomic, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityIndicatorItem;
@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, readonly) NJKWebViewProgressView *progressView;

@property (nonatomic, strong) NSURL *URL;

- (void)doneButtonClicked:(id)sender;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithLocalAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void)updateToolbarItems;
- (void)createToolbarItems;

@end
