//
//  JOSecondViewController.m
//  JOURLRouter
//
//  Created by huangqiaobo on 2017/6/26.
//  Copyright © 2017年 bobo. All rights reserved.
//

#import "JOSecondViewController.h"
@import JOURLRouter;

@interface JOSecondViewController () <JOURLRouterProtocol>
@property (copy, nonatomic) NSString *vcID;

@end

@implementation JOSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = self.vcID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSArray<NSString *> *)jo_viewControllerURLRegexPathArray {
    return @[@"/demo/second"];
}

+ (void)jo_matchingUrl:(NSString *)urlString matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler {
    NSDictionary *query = queryDicFromURLString(urlString);
    NSString *vcID = [query objectForKey:@"id"];

    JOSecondViewController *vc = [[JOSecondViewController alloc] init];
    vc.vcID = vcID;
    compeletionHandler(vc);
}

@end
