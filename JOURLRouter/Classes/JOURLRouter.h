//
//  JOURLRouter.h
//  Pods
//
//  Created by huangqiaobo on 2017/6/26.
//
//

#import <Foundation/Foundation.h>
#import "JOURLRouterProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 用于解析url的方法：将url中的query解析为NSDictionary

 @param urlStr url
 @return query dictionary
 */
NSDictionary * _Nullable queryDicFromURLString(NSString * _Nullable urlStr);

/**
 用于解析url的方法：将url中的path解析为NSArray

 @param urlStr url
 @return path array
 */
NSArray * _Nullable pathArrayFromURLString(NSString * _Nullable urlStr);

/**
 对JOURLJumpManager进行一些基本的配置的delegate protocol
 */
@protocol JOURLRouterDelegate <NSObject>

/**
 返回用于push出通过url所匹配到的vc的navigation controller

 @param vc 匹配到的 view controller
 @param urlStr url
 @return navigation controller
 */
- (UINavigationController * _Nullable)navigationControllerForPushVC:(UIViewController * _Nullable)vc url:(NSString * _Nullable)urlStr;

/**
 返回支持JOURLRouter跳转的hosts

 @return NSArray e.g. @[@"www.kujiale.com"];
 */
- (NSArray<NSString *> * _Nonnull)hostsForURLRouter;
@optional;


/**
 当url没有匹配到class的时候会调到这个方法，用于返回一个默认的vc。
 比如你可能会需要用一个包含webView的vc来handler这个url

 @param urlStr url
 @return view controller
 */
- (UIViewController * _Nullable)viewControllerForMatchingNativeVCFailedWithURLStr:(NSString * _Nullable)urlStr;

@end

typedef UIViewController * _Nullable (^JOURLRouterHandler)(UIViewController * _Nullable matchedVC);


@interface JOURLRouter : NSObject

+ (void)configWithDelegate:(_Nonnull id<JOURLRouterDelegate>)delegate;

/**
 compeletionHandler中返回通过url匹配到的vc

 @param urlStr url
 @param compeletionHandler JOMatchingCompeletionHandler
 */
+ (void)matchViewControllerWithURL:(NSString *)urlStr matchingCompeletionHandler:(_Nullable JOMatchingCompeletionHandler)compeletionHandler;

+ (void)openUrl:(NSString * _Nullable)urlStr;
+ (void)openUrl:(NSString * _Nullable)urlStr matchingCompeletionHandler:(_Nullable JOURLRouterHandler)compeletionHandler;
/**
 直接用提供的navigationController，push出url所匹配到的vc；

 @param urlStr url
 @param navigationController 如果为nil，会使用delegate中提供的navigation controller
 @param compeletionHandler 在push vc之前会调用这个block返回匹配到的vc，可以在这个block中做一些你需要的配置，如果你不想push出匹配到的vc，可以在这个block中返回nil，将不会push出这个vc，或者返回你想要的vc
 */
+ (void)openUrl:(NSString * _Nullable)urlStr withNavigationController:(UINavigationController * _Nullable)navigationController matchingCompeletionHandler:(_Nullable JOURLRouterHandler)compeletionHandler;


/**
 这个方法可以返回实现了JOURLRouterProtocol并且匹配urlStr的class

 @param urlStr url
 @return class
 */
+ (Class _Nullable)classForURLStr:(NSString * _Nullable)urlStr;

@end
NS_ASSUME_NONNULL_END
