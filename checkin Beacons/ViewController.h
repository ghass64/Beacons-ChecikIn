//
//  ViewController.h
//  checkin Beacons
//
//  Created by Ghassan ALMarei on 2/15/15.
//  Copyright (c) 2015 Ghassan ALMarei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeaconManager.h"
#import "UserSettings.h"
#import "GenericMethods.h"

@interface ViewController : UIViewController<ESTBeaconManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *clockinBtn;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;
@property (nonatomic, strong) ESTBeacon* beaconObj;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *timeLbl;
@property (strong, nonatomic) IBOutlet UITableView *timingTable;
@property (strong, nonatomic) IBOutlet UILabel *btnLabel;

- (IBAction)syncBeaconInvoked:(UIButton*)sender;
- (IBAction)clearInvoked:(id)sender;
@end

