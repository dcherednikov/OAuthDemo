//
//  WebVC.h
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Coordinator;

@interface WebVC : UIViewController

@property (nonatomic, weak) Coordinator *coordinator;

- (void)openURL:(NSURL *)url;

@end
