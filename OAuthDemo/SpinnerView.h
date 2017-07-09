//
//  SpinnerView.h
//  OAuthDemo
//
//  Created by Admin on 25/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinnerView : UIView

- (void)appearWithMessage:(NSString *)message;
- (void)disappear;

@property (nonatomic, weak) UIView *containerView;

@end
