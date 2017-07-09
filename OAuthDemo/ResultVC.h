//
//  ResultVC.h
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Messaging.h"

@class Coordinator;

@interface ResultVC : UIViewController <Messaging>

@property (nonatomic, weak) Coordinator *coordinator;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *accessTokenSecret;

@end
