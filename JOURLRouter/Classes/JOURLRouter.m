//
//  JOURLRouter.m
//  Pods
//
//  Created by huangqiaobo on 2017/6/26.
//
//

#import "JOURLRouter.h"
#import <objc/runtime.h>

const char * URL_ROUTER_QUEUQ_LABEL = "com.kujiale.www.queue.serial.url.router";

BOOL isStringNullOrEmpty(NSString *string) {
    return (string == nil || ([string isKindOfClass:[NSString class]] && string.length == 0));
}

NSDictionary * queryDicFromURLString(NSString *urlStr) {
    if (urlStr == nil) {
        return nil;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlStr];
    NSArray<NSURLQueryItem *> *parameters = urlComponents.queryItems;
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:parameters.count];
    for (NSURLQueryItem *item in parameters) {
        if (!isStringNullOrEmpty(item.value)) {
            [resultDic setObject:item.value forKey:item.name];
        }
    }
    return resultDic;
}

NSArray * pathArrayFromURLString(NSString *urlStr) {
    if (urlStr == nil) {
        return nil;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlStr];
    return urlComponents.path.pathComponents;
}

@interface JOURLRouter ()

@property (weak, nonatomic) id<JOURLRouterDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary<NSPredicate *, Class> *pathDic;
@property (assign, nonatomic) BOOL processing;
@property (assign, nonatomic) BOOL didProcessed;

@property (strong, nonatomic) dispatch_queue_t viewJumpQueue;

@end

@implementation JOURLRouter

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _viewJumpQueue = dispatch_queue_create(URL_ROUTER_QUEUQ_LABEL, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - getter and setter

- (NSMutableDictionary<NSPredicate *,Class> *)pathDic {
    if (_pathDic == nil) {
        _pathDic = [NSMutableDictionary dictionary];
    }
    return _pathDic;
}

#pragma mark - public method

+ (void)configWithDelegate:(id<JOURLRouterDelegate>)delegate {
    NSParameterAssert(delegate);
    [JOURLRouter sharedInstance].delegate = delegate;
    [[JOURLRouter sharedInstance] processClass];
}

+ (Class)classForURLStr:(NSString *)urlStr {
    return [[JOURLRouter sharedInstance] classForURLStr:urlStr];
}

+ (void)matchViewControllerWithURL:(NSString *)urlStr matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler {
    [[JOURLRouter sharedInstance] matchViewControllerWithURL:urlStr matchingCompeletionHandler:compeletionHandler];
}

+ (void)openUrl:(NSString *)urlStr {
    [JOURLRouter openUrl:urlStr matchingCompeletionHandler:nil];
}

+ (void)openUrl:(NSString *)urlStr matchingCompeletionHandler:(JOURLRouterHandler)compeletionHandler {
    [[JOURLRouter sharedInstance] openUrl:urlStr matchingCompeletionHandler:compeletionHandler];
}

+ (void)openUrl:(NSString *)urlStr withNavigationController:(UINavigationController *)navigationController matchingCompeletionHandler:(JOURLRouterHandler)compeletionHandler {
    [[JOURLRouter sharedInstance] openUrl:urlStr withNavigationController:navigationController matchingCompeletionHandler:compeletionHandler];
}

#pragma mark - private method

- (void)processClass {
    if ((!self.didProcessed) && (!self.processing)) {
        self.processing = YES;
        [self dispatchInViewJumpQueue:^{
#if defined(DEBUG)
            NSDate *date0 = [NSDate date];
#endif
            [self startProcessClass];
#if defined(DEBUG)
            NSDate *date1 = [NSDate date];
            NSLog(@"JOURLRouter processClass:%f",date1.timeIntervalSinceReferenceDate - date0.timeIntervalSinceReferenceDate);
#endif
            self.processing = NO;
            self.didProcessed = YES;
        }];
    }
}

- (Class)classForURLStr:(NSString *)urlStr {
    __block Class resultClass;
    if (self.processing) {
        dispatch_sync(self.viewJumpQueue, ^{
            Class<JOURLRouterProtocol> class = [self registeredClassForJumpWithURL:urlStr];
            resultClass = class;
        });
    } else {
        resultClass = [self registeredClassForJumpWithURL:urlStr];
    }
    return resultClass;
}

- (void)openUrl:(NSString *)urlStr matchingCompeletionHandler:(JOURLRouterHandler)compeletionHandler {
    [self openUrl:urlStr withNavigationController:nil matchingCompeletionHandler:compeletionHandler];
}

- (void)openUrl:(NSString *)urlStr withNavigationController:(UINavigationController *)navigationController matchingCompeletionHandler:(JOURLRouterHandler)compeletionHandler {
    [self matchViewControllerWithURL:urlStr matchingCompeletionHandler:^(UIViewController *matchedVC) {
        matchedVC.hidesBottomBarWhenPushed = YES;
        if (compeletionHandler != nil) {
            matchedVC = compeletionHandler(matchedVC);
        }
        if (matchedVC != nil) {
            void (^block)() = ^() {
                if (navigationController != nil) {
                    [navigationController pushViewController:matchedVC animated:YES];
                } else {
                    UINavigationController *navVC = [self.delegate navigationControllerForPushVC:matchedVC url:urlStr];
                    [navVC pushViewController:matchedVC animated:YES];
                }
            };
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        }
    }];
}

- (void)matchViewControllerWithURL:(NSString *)urlStr matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler {
    if (urlStr.length == 0) {
        if (compeletionHandler != nil) {
            compeletionHandler(nil);
        }
        return;
    }
    if (self.processing) {
        dispatch_sync(self.viewJumpQueue, ^{
            [self matchViewControllerForURL:urlStr matchingCompeletionHandler:^(UIViewController *matchedVC) {
                if (compeletionHandler != nil) {
                    compeletionHandler(matchedVC);
                }
            }];
        });
    } else {

        [self matchViewControllerForURL:urlStr matchingCompeletionHandler:compeletionHandler];
    }
}

- (void)matchViewControllerForURL:(NSString *)urlStr matchingCompeletionHandler:(JOMatchingCompeletionHandler)compeletionHandler {
    Class<JOURLRouterProtocol> class = [self registeredClassForJumpWithURL:urlStr];
    if (class == NULL) {
        if ([self.delegate respondsToSelector:@selector(viewControllerForMatchingNativeVCFailedWithURLStr:)]) {
            UIViewController *vc = [self.delegate viewControllerForMatchingNativeVCFailedWithURLStr:urlStr];
            if (compeletionHandler != nil) {
                compeletionHandler(vc);
            }
            return;
        }
    } else {
        [class jo_matchingUrl:urlStr matchingCompeletionHandler:compeletionHandler];
        return;
    }
    if (compeletionHandler != nil) {
        compeletionHandler(nil);
    }
}

- (Class<JOURLRouterProtocol>)registeredClassForJumpWithURL:(NSString *)urlString {
    NSString *lowString = urlString.lowercaseString;
    NSURLComponents *lowCaseUrlComponents = [NSURLComponents componentsWithString:lowString];
    NSUInteger length = 0;
    Class resultClass = nil;
    NSString *host = lowCaseUrlComponents.port == nil ? lowCaseUrlComponents.host : [NSString stringWithFormat:@"%@:%@", lowCaseUrlComponents.host,lowCaseUrlComponents.port.stringValue];
    BOOL shouldHandle = NO;
    NSArray *hostsForURLJump = [self.delegate hostsForURLRouter];
    for (NSString *hostForJump in hostsForURLJump) {
        if ([host isEqualToString:hostForJump]) {
            shouldHandle = YES;
            break;
        }
    }
    if (!shouldHandle) {
        return nil;
    }
    for (NSPredicate *test in self.pathDic.allKeys) {
        if ([test evaluateWithObject:lowCaseUrlComponents.path]) {
            if (test.predicateFormat.length > length) {
                resultClass = self.pathDic[test];
                break;
            }
        }
    }

    return resultClass;
}

- (void)startProcessClass {
    NSUInteger numClasses = 0;
    Class *classes = NULL;
    while (numClasses == 0) {
        numClasses = (NSUInteger)MAX(objc_getClassList(NULL, 0), 0);
        NSUInteger bufferSize = numClasses;
        classes = numClasses ? (Class *)malloc(sizeof(Class) * bufferSize) : NULL;
        if (classes == NULL) {
            return; //no memory or classes?
        }
        numClasses = (NSUInteger)MAX(objc_getClassList(classes, (int)bufferSize),0);
        if (numClasses > bufferSize || numClasses == 0) {
            free(classes);
            numClasses = 0;
        }
    }
    for (NSUInteger i = 0; i < numClasses; i++) {
        Class class = classes[i];
        BOOL comf = class_conformsToProtocol(object_getClass(class),@protocol(JOURLRouterProtocol));
        if (comf) {
            if ([self implementProtocolWithClass:class]) {
                NSArray<NSString *> *urlPaths = [class jo_viewControllerURLRegexPathArray];
                [self addClass:class forURLRegexPaths:urlPaths];
            } else {
                NSLog(@"%@ did not implement JOURLJumpProtocol", class);
            }
        }
    }

    free(classes);
    return;
}

- (BOOL)implementProtocolWithClass:(Class)class {
    unsigned int methodCount, i;
    Method *methodList = class_copyMethodList(object_getClass(class), &methodCount);
    SEL getterViewControllerURLPathArraySel = @selector(jo_viewControllerURLRegexPathArray);
    SEL matchingUrlSel = @selector(jo_matchingUrl:matchingCompeletionHandler:);
    if (methodList != NULL) {
        BOOL getterViewControllerURLPathArrayFound = NO;
        BOOL matchingUrlFound = NO;

        for (i = 0; i < methodCount; ++i) {
            SEL currentSel = method_getName(methodList[i]);

            if (currentSel == getterViewControllerURLPathArraySel) {
                getterViewControllerURLPathArrayFound = YES;
            } else if (currentSel == matchingUrlSel) {
                matchingUrlFound = YES;
            }

            if (getterViewControllerURLPathArrayFound && matchingUrlFound) {
                free(methodList);
                return YES;
            }
        }

        free(methodList);
    }
    return NO;
}

- (void)addClass:(Class)class forURLRegexPaths:(NSArray<NSString *> *)urlPaths {
    for (NSString *urlPath in urlPaths) {
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlPath];
        self.pathDic[test] = class;
    }
}

- (void)dispatchInViewJumpQueue:(dispatch_block_t)block {
    const char * label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    if (strcmp(label,URL_ROUTER_QUEUQ_LABEL) == 0) {
        block();
    } else {
        dispatch_async(self.viewJumpQueue, block);
    }
}

@end
