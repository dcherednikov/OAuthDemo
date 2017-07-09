//
//  AppDelegate.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "Coordinator.h"

@interface AppDelegate () {

    Coordinator *coordinator;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    coordinator = [[Coordinator alloc] initWithNavigationController:navigationController];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:frame];
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];

    [coordinator startFromRoot];
    
    return YES;
}

@end
