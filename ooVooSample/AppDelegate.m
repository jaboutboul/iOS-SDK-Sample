//
// AppDelegate.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "AppDelegate.h"
#import "ooVooController.h"
#import "MainViewController.h"

@interface AppDelegate ()
{
    BOOL cameraWasStoppedByEnteringBackground;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([ooVooController sharedController].cameraEnabled)
    {
        // sends "Turned off camera" to other participants so they don't just see a frozen video
        [ooVooController sharedController].cameraEnabled = NO;
        cameraWasStoppedByEnteringBackground = YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (cameraWasStoppedByEnteringBackground)
    {
        // sends "Turned on camera" to other participants so they can resume displaying our video
        [ooVooController sharedController].cameraEnabled = YES;
        cameraWasStoppedByEnteringBackground = NO;
    }
}

@end
