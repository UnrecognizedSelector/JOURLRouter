//
//  JOAppDelegate.m
//  JOURLRouter
//
//  Created by bobo on 06/26/2017.
//  Copyright (c) 2017 bobo. All rights reserved.
//

#import "JOAppDelegate.h"
@import JOURLRouter;

@interface JOAppDelegate () <JOURLRouterDelegate>

@end

@implementation JOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [JOURLRouter configWithDelegate:self];
    return YES;
}


- (UINavigationController * _Nullable)navigationControllerForPushVC:(UIViewController * _Nullable)vc url:(NSString * _Nullable)urlStr {
    UIViewController *rootVC = self.window.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController  class]]) {
        return (UINavigationController *)rootVC;
    }
    return nil;
}

- (NSArray<NSString *> * _Nonnull)hostsForURLRouter {
    return @[@"www.kujiale.com"];
}

@end
