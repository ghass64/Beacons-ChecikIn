//
//  beaconsTableVC.h
//  checkin Beacons
//
//  Created by Ghassan ALMarei on 2/15/15.
//  Copyright (c) 2015 Ghassan ALMarei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeaconManager.h"
#import "ESTBeacon.h"
#import "UserSettings.h"
#import "ViewController.h"

typedef enum : int
{
    ESTScanTypeBluetooth,
    ESTScanTypeBeacon
    
} ESTScanType;


@interface beaconsTableVC : UIViewController<ESTBeaconManagerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;

@property (nonatomic, assign)   ESTScanType scanType;
@property (weak, nonatomic) IBOutlet UITableView *beaconTableView;

@end
