//
//  Coordinator.h
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UINavigationController;

NS_ASSUME_NONNULL_BEGIN

@interface Coordinator : NSObject

- (void)startFromRoot;
- (void)onAuthorizationRequested;
- (void)onAuthorizationEnded;
- (void)onVerifierInfoProvided:(nullable NSString *)verifier;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
