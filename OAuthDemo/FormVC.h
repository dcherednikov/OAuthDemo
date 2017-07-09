//
//  KeySecretVC.h
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Messaging.h"


@class Coordinator;

@interface FormVC : UIViewController <Messaging>

@property (nonatomic, weak) Coordinator *coordinator;
@property (nonatomic, copy) NSString *consumerKeyFieldText;
@property (nonatomic, copy) NSString *consumerSecretFieldText;
@property (nonatomic, copy) NSString *requestURLFieldText;
@property (nonatomic, copy) NSString *authorizationURLFieldText;
@property (nonatomic, copy) NSString *accessURLFieldText;

@end
