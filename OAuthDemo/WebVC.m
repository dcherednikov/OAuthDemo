//
//  WebVC.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WebVC.h"
#import "Coordinator.h"


@interface WebVC () {
    
    IBOutlet UIWebView *webView;
}

@end


@implementation WebVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(doneButtonTapped)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - public

- (void)openURL:(NSURL *)url {
 
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma mark - private

- (void)doneButtonTapped {
    
    [_coordinator onAuthorizationEnded];
}

@end
