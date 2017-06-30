//
//  JOViewController.m
//  JOURLRouter
//
//  Created by bobo on 06/26/2017.
//  Copyright (c) 2017 bobo. All rights reserved.
//

#import "JOViewController.h"
@import JOURLRouter;

@interface JOViewController ()

@end

@implementation JOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushFirstVC:(id)sender {
    [JOURLRouter openUrl:@"https://www.kujiale.com/demo/first/firstvc"];
}

- (IBAction)pushSecondVC:(id)sender {
    [JOURLRouter openUrl:@"https://www.kujiale.com/demo/second?id=secondvc" matchingCompeletionHandler:^UIViewController * _Nullable(UIViewController * _Nullable matchedVC) {
        
        return matchedVC;
    }];
}

@end
