//
//  MessageView.h
//  OAuthDemo
//
//  Created by Admin on 26/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

- (void)appearWithMessage:(NSString *)message;

@property (nonatomic, weak) UIView *containerView;

@end
