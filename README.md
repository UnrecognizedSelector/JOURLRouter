# JOURLRouter

[![CI Status](http://img.shields.io/travis/bobo/JOURLRouter.svg?style=flat)](https://travis-ci.org/bobo/JOURLRouter)
[![Version](https://img.shields.io/cocoapods/v/JOURLRouter.svg?style=flat)](http://cocoapods.org/pods/JOURLRouter)
[![License](https://img.shields.io/cocoapods/l/JOURLRouter.svg?style=flat)](http://cocoapods.org/pods/JOURLRouter)
[![Platform](https://img.shields.io/cocoapods/p/JOURLRouter.svg?style=flat)](http://cocoapods.org/pods/JOURLRouter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 8.0 or later
## Installation

JOURLRouter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JOURLRouter"
```
## Usage
1. create a instance which implement the protocol JOURLRouterDelegate

2. configure JOURLRouter
   #### Example:
   ```ObjC
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
   ```
3. implement the protocol JOURLRouterProtocol
   #### Example:
   ```ObjC
   @interface JOFirstViewController () <JOURLRouterProtocol>
   @end
   ```
   ```ObjC
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
   ```
4. Then you can use ```[JOURLRouter openUrl:@"https://www.kujiale.com/demo/first/firstvc"]```to push JOFirstViewController without importing it

## Author

bobo@qunhemail.com

## License

JOURLRouter is available under the MIT license. See the LICENSE file for more info.
