//
//  AppDelegate.m
//  checkin Beacons
//
//  Created by Ghassan ALMarei on 2/15/15.
//  Copyright (c) 2015 Ghassan ALMarei. All rights reserved.
//

#import "AppDelegate.h"
#import <ESTBeaconManager.h>
#import <ESTConfig.h>
#import "UserSettings.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Prepare the notification to be interactive
    UIMutableUserNotificationAction * checkAction = [[UIMutableUserNotificationAction alloc] init];
    checkAction.identifier = @"CHECKED_IDENT";
    checkAction.title = @"Yes";
    checkAction.activationMode = UIUserNotificationActivationModeBackground;
    checkAction.destructive = YES;
    checkAction.authenticationRequired = NO;
    
    
    UIMutableUserNotificationAction * dismissAction = [[UIMutableUserNotificationAction alloc] init];
    dismissAction.identifier = @"DISMISS_IDENT";
    dismissAction.title = @"No";
    dismissAction.activationMode = UIUserNotificationActivationModeBackground;
    dismissAction.destructive = YES;
    dismissAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *checkCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    checkCategory.identifier = @"CHECK_CATEGORY";
    
    [checkCategory setActions:@[checkAction, dismissAction]
                   forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObjects:checkCategory, nil];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:categories]];
    }
    
    
    
    //connect the beacon estimote account
    [ESTConfig setupAppID:@"app_1e8bwn0cn8" andAppToken:@"8a6b03479cd36d91d9a81521f91c5105"];
    [ESTConfig enableAnalytics:YES];
    
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    
    //check if its the first time to synchronize with beacons
    if(![UserSettings syncHasBeenShown])
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        self.nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FirstTimeSync"];
        
        self.window.rootViewController = self.nc;
        return YES;
        
        
    }else
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        self.nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DefaultNavigation"];
        
        self.window.rootViewController = self.nc;
        return YES;
    }
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    NSLog(@"recieve local , %@",notification.alertBody);
    NSDictionary* userInfo = notification.userInfo;
    NotifyDict = userInfo;
    NSString* checkType = userInfo[@"Type"];
    
    //after recieving the local notify, we check if its entering or exiting
    if ([checkType isEqualToString:@"In"]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Clock In" message:@"Would you like to clock in the system?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 1;
        [alert show];
        return;
        
    }else if ([checkType isEqualToString:@"Out"])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Clock Out" message:@"Would you like to clock out from the system?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 2;
        [alert show];
        return;
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDate* today = [NSDate date];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE,d MMM yyyy"];
    NSString* todayDate = [df stringFromDate:today];
    
    NSDateFormatter* dfTime = [[NSDateFormatter alloc] init];
    [dfTime setDateFormat:@"hh:mm:ss a"];
    NSString* todayTime = [dfTime stringFromDate:today];
    
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0) {
            //get the cached array
            NSMutableArray* timingArr = [[NSMutableArray alloc]initWithArray:[GenericMethods getCachedTimingList]];
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            dict[@"dateTime"] = today;
            dict[@"date"] = todayDate;
            dict[@"time"] = todayTime;
            dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",NotifyDict[@"UDID"]];
            dict[@"Type"] = @"In";
            
            [timingArr addObject:dict];
            
            //add the timing to the cached array to show in VC
            BOOL cached = [GenericMethods cacheTimingList:timingArr];
            
            //change the flag to checked in
            [UserSettings setCheckIn:YES];
        }
        else
        {
            alertView.hidden = YES;
        }
    }else if (alertView.tag == 2)
    {
        if (buttonIndex == 0) {
            //get the cached array
            NSMutableArray* timingArr = [[NSMutableArray alloc]initWithArray:[GenericMethods getCachedTimingList]];
            NSMutableDictionary* dict = [NSMutableDictionary new];
            dict[@"dateTime"] = today;
            dict[@"date"] = todayDate;
            dict[@"time"] = todayTime;
            dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",NotifyDict[@"UDID"]];
            dict[@"Type"] = @"Out";
            
            [timingArr addObject:dict];
            
            //add the timing to the cached array to show in VC
            BOOL cached = [GenericMethods cacheTimingList:timingArr];
            
            //change the flag to checked out
            [UserSettings setCheckIn:NO];
        }
        else
        {
            alertView.hidden = YES;
        }
    }
    //trigger the observer to change the data in VC
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckinSucceed"
                                                        object:nil];
    
    //clear all notification in the notification center
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;

    
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    //handle the actions with the same methods in "clickedButtonAtIndex"
    if ([identifier isEqualToString:@"CHECKED_IDENT"]){
       
        NSDictionary* userInfo = notification.userInfo;
        NotifyDict = userInfo;
        NSString* checkType = userInfo[@"Type"];
        
        if ([checkType isEqualToString:@"In"]) {
            NSDate* today = [NSDate date];
            
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE,d MMM yyyy"];
            NSString* todayDate = [df stringFromDate:today];
            
            NSDateFormatter* dfTime = [[NSDateFormatter alloc] init];
            [dfTime setDateFormat:@"hh:mm:ss a"];
            NSString* todayTime = [dfTime stringFromDate:today];
            
            NSMutableArray* timingArr = [[NSMutableArray alloc]initWithArray:[GenericMethods getCachedTimingList]];
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            dict[@"dateTime"] = today;
            dict[@"date"] = todayDate;
            dict[@"time"] = todayTime;
            dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",NotifyDict[@"UDID"]];
            dict[@"Type"] = @"In";
            
            [timingArr addObject:dict];
            
            BOOL cached = [GenericMethods cacheTimingList:timingArr];
            
            
            [UserSettings setCheckIn:YES];
            
            
        }else if ([checkType isEqualToString:@"Out"])
        {
            NSDate* today = [NSDate date];
            
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE,d MMM yyyy"];
            NSString* todayDate = [df stringFromDate:today];
            
            NSDateFormatter* dfTime = [[NSDateFormatter alloc] init];
            [dfTime setDateFormat:@"hh:mm:ss a"];
            NSString* todayTime = [dfTime stringFromDate:today];
           
            
            NSMutableArray* timingArr = [[NSMutableArray alloc]initWithArray:[GenericMethods getCachedTimingList]];
            NSMutableDictionary* dict = [NSMutableDictionary new];
            dict[@"dateTime"] = today;
            dict[@"date"] = todayDate;
            dict[@"time"] = todayTime;
            dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",NotifyDict[@"UDID"]];
            dict[@"Type"] = @"Out";
            
            [timingArr addObject:dict];
            
            BOOL cached = [GenericMethods cacheTimingList:timingArr];
            
            
            [UserSettings setCheckIn:NO];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckinSucceed"
                                                            object:nil];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber = -1;


    }
    else if ([identifier isEqualToString:@"DISMISS_IDENT"]){
        
    }
    
    if (completionHandler) {
        
        completionHandler();
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"go background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"go forground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
