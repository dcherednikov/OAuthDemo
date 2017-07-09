//
//  Messaging.h
//  OAuthDemo
//
//  Created by Admin on 26/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

@protocol Messaging <NSObject>

- (void)askToWait;
- (void)stopWaiting;
- (void)informOnFailure;

@end
