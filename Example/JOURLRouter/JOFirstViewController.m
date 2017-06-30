//
//  JOFirstViewController.m
//  JOURLRouter
//
//  Created by huangqiaobo on 2017/6/26.
//  Copyright © 2017年 bobo. All rights reserved.
//

#import "JOFirstViewController.h"

@import JOURLRouter;

@interface JOFirstViewController () <JOURLRouterProtocol>
@property (copy, nonatomic) NSString *vcID;
@end

@implementation JOFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.vcID;
}

+ (NSArray<NSString *> *)jo_viewControllerURLRegexPathArray {
    return @[@"/demo/first/.+"];
}

+ (void)jo_matchingUrl:(NSString *)urlString matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler {
    NSArray *path = pathArrayFromURLString(urlString);
    NSString *vcID = [path lastObject];

    JOFirstViewController *vc = [[JOFirstViewController alloc] init];
    vc.vcID = vcID;
    compeletionHandler(vc);
}

@end
