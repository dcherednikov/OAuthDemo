//
//  MessageView.m
//  OAuthDemo
//
//  Created by Admin on 26/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "MessageView.h"

@interface MessageView () {
    
    IBOutlet UILabel *messageLabel;
}

@end

@implementation MessageView

- (void)appearWithMessage:(NSString *)message {
    
    messageLabel.text = message;
    self.frame = _containerView.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_containerView addSubview:self];
}

- (IBAction)OKButtonPressed:(id)sender {
    
    [self removeFromSuperview];
}

@end
