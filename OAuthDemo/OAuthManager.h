//
//  OAuthManager.h
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OAuthManagerDelegate <NSObject>

- (void)firstRequestSucceeded;
- (void)firstRequestFailed;
- (void)secondRequestSucceeded;
- (void)secondRequestFailed;

@end

typedef NS_ENUM(NSUInteger, OAuthStatus) {
    
    OAuthStatusNone,
    OAuthStatusPerformingFirstRequest,
    OAuthStatusFirstRequestSucceeded,
    OAuthStatusFirstRequestFailed,
    OAuthStatusPerformingSecondRequest,
    OAuthStatusSecondRequestSucceeded,
    OAuthStatusSecondRequestFailed
};


@interface OAuthManager : NSObject

@property (nonatomic, weak) id<OAuthManagerDelegate> delegate;
@property (nonatomic, assign) OAuthStatus status;

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;

@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, copy) NSString *authorizationURL;
@property (nonatomic, copy) NSString *accessURL;

@property (nonatomic, readonly, copy) NSString *encodedAuthorizationURL;
@property (nonatomic, readonly, copy) NSString *accessToken;
@property (nonatomic, readonly, copy) NSString *accessTokenSecret;

- (void)requestFirstPair;
- (void)requestAccessPair;
- (void)requestAccessPairWithVerifier:(NSString *)verifier;

@end
