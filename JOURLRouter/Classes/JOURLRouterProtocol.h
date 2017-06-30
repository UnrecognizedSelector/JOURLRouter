//
//  JOURLRouterProtocol.h
//  Pods
//
//  Created by huangqiaobo on 2017/6/26.
//
//

#ifndef JOURLRouterProtocol_h
#define JOURLRouterProtocol_h

typedef void(^JOMatchingCompeletionHandler)(UIViewController *matchedVC);

@protocol JOURLRouterProtocol <NSObject>

+ (NSArray<NSString *> *)jo_viewControllerURLRegexPathArray;

+ (void)jo_matchingUrl:(NSString *)urlString matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler;

@end

#endif /* JOURLRouterProtocol_h */
