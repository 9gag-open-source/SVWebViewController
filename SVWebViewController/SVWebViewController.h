//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"

@protocol SVWebViewControllerShareDelegate <NSObject>
@required
@optional
-(void)shareURL:(NSURL *)url withTitle:(NSString *)title fromViewController:(UIViewController *)viewController;
@end

@interface SVWebViewController : UIViewController



@property(nonatomic, weak) id <SVWebViewControllerShareDelegate> shareDelegate;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

@end
