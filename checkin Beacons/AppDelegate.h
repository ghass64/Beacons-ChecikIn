//
//  AppDelegate.h
//  checkin Beacons
//
//  Created by Ghassan ALMarei on 2/15/15.
//  Copyright (c) 2015 Ghassan ALMarei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericMethods.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSDictionary* NotifyDict;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyboardVC;
@property (nonatomic, retain) UINavigationController *nc;


@end

