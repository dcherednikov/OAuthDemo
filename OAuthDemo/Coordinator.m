//
//  Coordinator.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "Coordinator.h"
#import <UIKit/UIKit.h>
#import "FormVC.h"
#import "ResultVC.h"
#import "VerifierVC.h"
#import "WebVC.h"
#import "OAuthManager.h"


@interface Coordinator () <OAuthManagerDelegate> {

    UINavigationController *navigationController;
    FormVC *formVC;
    WebVC *webVC;
    VerifierVC *verifierVC;
    ResultVC *resultVC;
    
    OAuthManager *authorizationManager;
    
    NSTimer *waitingTimer;
}

@end

static const NSString *keyConsumerKey = @"Consumer Key";
static const NSString *keyConsumerSecret = @"Consumer Secret";
static const NSString *keyRequestURL = @"Request URL";
static const NSString *keyAuthorizationURL = @"Authorization URL";
static const NSString *keyAccessURL = @"Access URL";

@implementation Coordinator

#pragma mark - constructor 

- (instancetype)initWithNavigationController:(UINavigationController *)controller {

    self = [super init];
    if (self) {
       
        navigationController = controller;
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        formVC = [[mainBundle loadNibNamed:@"FormVC"
                                     owner:nil
                                   options:nil] firstObject];
        webVC = [[mainBundle loadNibNamed:@"WebVC"
                                    owner:nil
                                  options:nil] firstObject];
        resultVC = [[mainBundle loadNibNamed:@"ResultVC"
                                       owner:nil
                                     options:nil] firstObject];
        verifierVC = [[mainBundle loadNibNamed:@"VerifierVC"
                                         owner:nil
                                       options:nil] firstObject];
        
        formVC.coordinator = self;
        webVC.coordinator = self;
        verifierVC.coordinator = self;
        resultVC.coordinator = self;
        
        authorizationManager = [[OAuthManager alloc] init];
        authorizationManager.delegate = self;
        [self setupAuthorizationManager];
    }
    
    return self;
}

#pragma mark - public

- (void)startFromRoot {
    
    if (!navigationController.topViewController) {
        
        [navigationController pushViewController:formVC animated:NO];
    }
    else {
        
        [navigationController popToRootViewControllerAnimated:YES];
    }
    
    [self fillForm];
}

- (void)onAuthorizationRequested {
   
    [self saveFields];
    [formVC askToWait];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                    target:self
                                                  selector:@selector(waitingTimerFiredOnFirstRequest)
                                                  userInfo:nil
                                                   repeats:NO];
    [authorizationManager requestFirstPair];
}

- (void)onAuthorizationEnded {
    
    [self presentVerifierVC];
}

- (void)onVerifierInfoProvided:(NSString *)verifier {
    
    [self presentResultVC];
    [resultVC askToWait];
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                    target:self
                                                  selector:@selector(waitingTimerFiredOnAccessRequest)
                                                  userInfo:nil
                                                   repeats:NO];
    if (verifier && ![verifier isEqualToString:@""]) {
        
        [authorizationManager requestAccessPairWithVerifier:verifier];
    }
    else {
        
        [authorizationManager requestAccessPair];
    }
}
#pragma mark - VC presentation

- (void)presentWebVC {
    
    [navigationController pushViewController:webVC
                                     animated:YES];
    NSURL *url = [NSURL URLWithString:authorizationManager.encodedAuthorizationURL];
    [webVC openURL:url];
}

- (void)presentResultVC {
    
    [navigationController pushViewController:resultVC animated:YES];
}

- (void)presentVerifierVC {
    
    [navigationController pushViewController:verifierVC animated:YES];
}

#pragma mark - form handling

- (void)setupAuthorizationManager {
    
    authorizationManager.consumerKey = [[NSUserDefaults standardUserDefaults] valueForKey:[keyConsumerKey copy]];
    authorizationManager.consumerSecret = [[NSUserDefaults standardUserDefaults] valueForKey:[keyConsumerSecret copy]];
    authorizationManager.requestURL = [[NSUserDefaults standardUserDefaults] valueForKey:[keyRequestURL copy]];
    authorizationManager.authorizationURL = [[NSUserDefaults standardUserDefaults] valueForKey:[keyAuthorizationURL copy]];
    authorizationManager.accessURL = [[NSUserDefaults standardUserDefaults] valueForKey:[keyAccessURL copy]];
}

- (void)fillForm {

    formVC.consumerKeyFieldText = authorizationManager.consumerKey;
    formVC.consumerSecretFieldText = authorizationManager.consumerSecret;
    formVC.requestURLFieldText = authorizationManager.requestURL;
    formVC.authorizationURLFieldText = authorizationManager.authorizationURL;
    formVC.accessURLFieldText = authorizationManager.accessURL;
}

- (void)saveFields {
    
    authorizationManager.consumerKey = formVC.consumerKeyFieldText;
    authorizationManager.consumerSecret = formVC.consumerSecretFieldText;
    authorizationManager.requestURL = formVC.requestURLFieldText;
    authorizationManager.authorizationURL = formVC.authorizationURLFieldText;
    authorizationManager.accessURL = formVC.accessURLFieldText;
    
    [[NSUserDefaults standardUserDefaults] setValue:formVC.consumerKeyFieldText
                                             forKey:[keyConsumerKey copy]];
    [[NSUserDefaults standardUserDefaults] setValue:formVC.consumerSecretFieldText
                                             forKey:[keyConsumerSecret copy]];
    [[NSUserDefaults standardUserDefaults] setValue:formVC.requestURLFieldText
                                             forKey:[keyRequestURL copy]];
    [[NSUserDefaults standardUserDefaults] setValue:formVC.authorizationURLFieldText
                                             forKey:[keyAuthorizationURL copy]];
    [[NSUserDefaults standardUserDefaults] setValue:formVC.accessURLFieldText
                                             forKey:[keyAccessURL copy]];
}

#pragma mark - timer handling

- (void)waitingTimerFiredOnFirstRequest {

    if (authorizationManager.status == OAuthStatusFirstRequestSucceeded) {
    
        [formVC stopWaiting];
        [self presentWebVC];
    }
    else if (authorizationManager.status == OAuthStatusFirstRequestFailed) {
        
        [formVC stopWaiting];
        [formVC informOnFailure];
    }
    waitingTimer = nil;
}

- (void)waitingTimerFiredOnAccessRequest {
    
    if (authorizationManager.status == OAuthStatusSecondRequestSucceeded) {
        
        [resultVC stopWaiting];
        resultVC.accessToken = authorizationManager.accessToken;
        resultVC.accessTokenSecret = authorizationManager.accessTokenSecret;
    }
    else if (authorizationManager.status == OAuthStatusSecondRequestFailed) {
        
        [resultVC stopWaiting];
        [resultVC informOnFailure];
    }
    waitingTimer = nil;
}

#pragma mark - OAuthManagerDelegate

- (void)firstRequestSucceeded {
    
    if (waitingTimer) {
        
        return;
    }
    __weak __block typeof(self) weakSelf = self;
    void (^block)() = ^{
        
        typeof(self) strongSelf = weakSelf;
        [formVC stopWaiting];
        [strongSelf presentWebVC];
    };
    [self performOnUIThread:block];
}

- (void)firstRequestFailed {
    
    if (waitingTimer) {
        
        return;
    }
    void (^block)() = ^{
        
        [formVC stopWaiting];
        [formVC informOnFailure];
    };
    [self performOnUIThread:block];
}

- (void)secondRequestSucceeded {
    
    if (waitingTimer) {
        
        return;
    }
    void (^block)() = ^{
        
        [resultVC stopWaiting];
        resultVC.accessToken = authorizationManager.accessToken;
        resultVC.accessTokenSecret = authorizationManager.accessTokenSecret;
    };
    [self performOnUIThread:block];
}

- (void)secondRequestFailed {
    
    if (waitingTimer) {
        
        return;
    }
    void (^block)() = ^{
      
        [resultVC stopWaiting];
        [resultVC informOnFailure];
    };
    [self performOnUIThread:block];
}

#pragma mark - UI thread utility method

- (void)performOnUIThread:(void (^)(void))block {
    
    if ([NSThread currentThread].isMainThread) {
        
        block();
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
    
@end
