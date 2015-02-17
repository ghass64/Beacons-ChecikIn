//
//  ViewController.m
//  checkin Beacons
//
//  Created by Ghassan ALMarei on 2/15/15.
//  Copyright (c) 2015 Ghassan ALMarei. All rights reserved.
//

#import "ViewController.h"
#define BEACON_MAJOR 52348
#define BEACON_MINOR 19007

@interface ViewController ()
{
    NSTimer* timer;
    NSMutableArray* timingArr;
    NSArray *beaconsArray;
    BOOL isShown;
    
}
@end

@interface MyCell:UITableViewCell
@end
@implementation MyCell
-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle // or whatever style you want
                reuseIdentifier:reuseIdentifier];
    return self;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //observer to update the data when we use interactive notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareData)
                                                 name:@"CheckinSucceed"
                                               object:nil];
    
    
    self.title = @"Welcome";
    
    [self.timingTable registerClass:[MyCell class] forCellReuseIdentifier:@"TimingCell"];
    
    self.timingTable.layer.borderWidth = 1.0f;
    self.timingTable.layer.borderColor = [[UIColor blackColor] CGColor];
    self.timingTable.layer.masksToBounds = YES;
    
    [self initBeaconManager];
    [self initRegion];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //timer to make the clock ticking
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];

    [self prepareData];
    [self startMonitoring];
    

    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CheckinSucceed"
                                                  object:nil];
    
    [timer invalidate];
    
}

-(void)initBeaconManager
{
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
}

-(void)initRegion
{
    //NOTE :: put this data according to my Beacons device data , so you need to Change it according to yours
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                 major:BEACON_MAJOR
                                                                 minor:BEACON_MINOR                                                                identifier:@"RegionIdentifier"];
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;

    
}

- (void)startMonitoring {
    NSLog(@"Start monitoring");
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    [self.beaconManager requestStateForRegion:self.beaconRegion];
}


- (void)stopMonitoring {
    NSLog(@"Stop monitoring");
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
}


-(void)prepareData
{
    //reset the flag isShown
    isShown = NO;
    
    //get data from cache
    timingArr = [[NSMutableArray alloc]initWithArray:[GenericMethods getCachedTimingList]];
    
    if (!timingArr) {
        timingArr = [NSMutableArray new];
    }
    NSDate* today = [NSDate date];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE,d MMM yyyy"];
    self.dateLbl.text = [df stringFromDate:today];
    
    NSDateFormatter* dfTime = [[NSDateFormatter alloc] init];
    [dfTime setDateFormat:@"hh:mm:ss a"];
    self.timeLbl.text = [dfTime stringFromDate:today];
    
    if ([UserSettings CheckHasBeenChecked]) {
        self.btnLabel.text = @"Clock Out";
        self.clockinBtn.tag = 10;
        
    }else
    {
        self.btnLabel.text = @"Clock In";
        self.clockinBtn.tag = 0;
    }
    
    
    [self.timingTable reloadData];
}

-(void)timeTick
{
    NSDate* today = [NSDate date];
    
    NSDateFormatter* dfTime = [[NSDateFormatter alloc] init];
    [dfTime setDateFormat:@"hh:mm:ss a"];
    self.timeLbl.text = [dfTime stringFromDate:today];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)syncBeaconInvoked:(UIButton*)sender {
    if (sender.tag == 0) {
        NSMutableDictionary* dict = [NSMutableDictionary new];
        NSDate* today = [NSDate date];
        dict[@"dateTime"] = today;
        dict[@"date"] = self.dateLbl.text;
        dict[@"time"] = self.timeLbl.text;
        dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",self.beaconObj.proximityUUID];
        dict[@"Type"] = @"In";
        
        [timingArr addObject:dict];
        
        BOOL cached = [GenericMethods cacheTimingList:timingArr];
        
        [self.timingTable reloadData];
        
        [UserSettings setCheckIn:YES];
        self.btnLabel.text = @"Clock Out";
        self.clockinBtn.tag = 10;
        
        
    }
    else if (sender.tag == 10)
    {
        NSMutableDictionary* dict = [NSMutableDictionary new];
        NSDate* today = [NSDate date];
        dict[@"dateTime"] = today;
        dict[@"date"] = self.dateLbl.text;
        dict[@"time"] = self.timeLbl.text;
        dict[@"proximityUUID"] = [NSString stringWithFormat:@"%@",self.beaconObj.proximityUUID];
        dict[@"Type"] = @"Out";
        
        [timingArr addObject:dict];
        BOOL cached = [GenericMethods cacheTimingList:timingArr];
        
        [self.timingTable reloadData];
        
        [UserSettings setCheckIn:NO];
        self.btnLabel.text = @"Clock In";
        self.clockinBtn.tag = 0;
        
    }
    
}

- (IBAction)clearInvoked:(id)sender {
    [timingArr removeAllObjects];
    [GenericMethods clearCachedTimingList];
    
    [self.timingTable reloadData];
    
}


#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{

    NSLog(@"Entered region: %@", region);
    
        if (![UserSettings CheckHasBeenChecked]) {
            
            NSMutableDictionary* userInfoDict = [NSMutableDictionary new];
            userInfoDict[@"Type"] = @"In";
            userInfoDict[@"UDID"] = region.proximityUUID.UUIDString;
            
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = @"You are going in would you like to clock in?";
            notification.userInfo = userInfoDict;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.category = @"CHECK_CATEGORY";
            
            //check the the flag isShown then dont fire this notify because its already fired
            if (!isShown) {
                isShown = YES;
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
            }
        }
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    NSLog(@"Left region: %@", region);

        if ([UserSettings CheckHasBeenChecked]) {
            
            NSMutableDictionary* userInfoDict = [NSMutableDictionary new];
            userInfoDict[@"Type"] = @"Out";
            userInfoDict[@"UDID"] = region.proximityUUID.UUIDString;
            
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = @"You are going out would you like to clock out?";
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.userInfo = userInfoDict;
            notification.category = @"CHECK_CATEGORY";
            
            //check the the flag isShown then dont fire this notify because its already fired
            if (!isShown) {
                isShown = YES;
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
    
}


- (void)beaconManager:(ESTBeaconManager *)manager
    didDetermineState:(CLRegionState)state
            forRegion:(ESTBeaconRegion *)region {
    if (state == CLRegionStateInside) {
        NSLog(@"Determine inside region");
        if (![UserSettings CheckHasBeenChecked]) {
            
            NSMutableDictionary* userInfoDict = [NSMutableDictionary new];
            userInfoDict[@"Type"] = @"In";
            userInfoDict[@"UDID"] = region.proximityUUID.UUIDString;
            
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = @"You are going in would you like to clock in?";
            notification.userInfo = userInfoDict;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.category = @"CHECK_CATEGORY";
            
            //check the the flag isShown then dont fire this notify because its already fired
            if (!isShown) {
                isShown = YES;
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
        
    } else if (state == CLRegionStateOutside) {
        NSLog(@"Determine outside region");
        if ([UserSettings CheckHasBeenChecked]) {
            
            NSMutableDictionary* userInfoDict = [NSMutableDictionary new];
            userInfoDict[@"Type"] = @"Out";
            userInfoDict[@"UDID"] = region.proximityUUID.UUIDString;
            
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = @"You are going out would you like to clock out?";
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.userInfo = userInfoDict;
            notification.category = @"CHECK_CATEGORY";
            
            //check the the flag isShown then dont fire this notify because its already fired
            if (!isShown) {
                isShown = YES;
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timingArr count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimingCell";
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell==nil) {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    NSDictionary *dict = [timingArr objectAtIndex:indexPath.row];
    
    
    NSString* checkType = dict[@"Type"];
    if ([checkType isEqualToString:@"In"]) {
        cell.textLabel.text = @"Check In at:";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", dict[@"time"], dict[@"date"]];
        cell.imageView.image = [UIImage imageNamed:@"InImage"];
    }
    else if ([checkType isEqualToString:@"Out"])
    {
        cell.textLabel.text = @"Check Out at:";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", dict[@"time"], dict[@"date"]];
        cell.imageView.image = [UIImage imageNamed:@"outImage"];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


@end
