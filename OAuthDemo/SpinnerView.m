//
//  SpinnerView.m
//  OAuthDemo
//
//  Created by Admin on 25/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "SpinnerView.h"

@interface SpinnerView () {

    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *messageLabel;
}

@end


@implementation SpinnerView

- (void)appearWithMessage:(NSString *)message {
    
    messageLabel.text = message;
    self.frame = _containerView.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [spinner startAnimating];
    [_containerView addSubview:self];
}

- (void)disappear {
    
    [spinner stopAnimating];
    [self removeFromSuperview];
}

@end
