//
//  ResultVC.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "ResultVC.h"
#import "Coordinator.h"
#import "MessageView.h"
#import "SpinnerView.h"

@interface ResultVC () {
    
    MessageView *messageView;
    SpinnerView *spinnerView;
    
    IBOutlet UILabel *tokenLabel;
    IBOutlet UILabel *tokenSecretLabel;
}

@end

@implementation ResultVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    messageView = [[[NSBundle mainBundle] loadNibNamed:@"MessageView"
                                                 owner:nil
                                               options:nil] firstObject];
    messageView.containerView = self.view;
    spinnerView = [[[NSBundle mainBundle] loadNibNamed:@"SpinnerView"
                                                 owner:nil
                                               options:nil] firstObject];
    spinnerView.containerView = self.view;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - IBActions

- (IBAction)tryAgainButtonPressed:(id)sender {

    [_coordinator startFromRoot];
}

#pragma mark - public

- (void)setAccessToken:(NSString *)accessToken {

    if (accessToken && ![accessToken isEqualToString:@""]) {
        
        _accessToken = accessToken;
        tokenLabel.text = accessToken;
    }
    else {
        
        tokenLabel.text = @"no access token";
    }
}

- (void)setAccessTokenSecret:(NSString *)accessTokenSecret {
    
    if (accessTokenSecret && ![accessTokenSecret isEqualToString:@""]) {
        
        _accessTokenSecret = accessTokenSecret;
        tokenSecretLabel.text = accessTokenSecret;
    }
    else {
        
        tokenSecretLabel.text = @"no access token secret";
    }
}

#pragma mark - Messaging

- (void)askToWait {
    
    [spinnerView appearWithMessage:@"access token and token secret\nare requested..."];
}

- (void)stopWaiting {
    
    [spinnerView disappear];
}

- (void)informOnFailure {
    
    [messageView appearWithMessage:@"second request failed"];
    self.accessToken = nil;
    self.accessTokenSecret = nil;
}

@end
