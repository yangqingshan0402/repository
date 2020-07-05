//
//  AppDelegate.m
//  YGHTabBar
//
//  Created by YangGH on 16/5/3.
//  Copyright © 2016年 YangGH. All rights reserved.
//

#import "AppDelegate.h"

#import "jdy_scan_ble_ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    jdy_scan_ble_ViewController *rootViewController = [[jdy_scan_ble_ViewController alloc] init];
    UINavigationController *ct = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.backgroundColor=[UIColor whiteColor];
    //[self.window addSubview:ct.view];
    self.window.rootViewController = ct;
    [self.window makeKeyAndVisible];
    
    
    
    
    
    //    /*初始化视图*/
    //    CGRect frame = [[UIScreen mainScreen] bounds];//
    //    self.window = [[UIWindow alloc] initWithFrame:frame];
    //    self.window.backgroundColor = [UIColor blackColor];
    //    [self changeToHomeViewController];
    //    [self.window makeKeyAndVisible];
    
    
    return YES;
}




+ (AppDelegate *)currentAppDelegate
{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

#if kPanUISwitch
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == szListenTabbarViewMove)
    {
        NSValue *value  = [change objectForKey:NSKeyValueChangeNewKey];
        CGAffineTransform newTransform = [value CGAffineTransformValue];
        
        [self.screenshotView showEffectChange:CGPointMake(newTransform.tx, 0) ];
    }
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}













@end
