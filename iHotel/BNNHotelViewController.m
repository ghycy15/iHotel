//
//  BNNHotelViewController.m
//  iHotel
//
//  Created by Lirong Yuan on 4/8/14.
//  Copyright (c) 2014 Banana. All rights reserved.
//

#import "BNNCustomer.h"
#import "BNNHotelViewController.h"



#define DEBUG  1

@interface BNNHotelViewController () <CLLocationManagerDelegate, BNNCustomerDelegate>
/* DEBUG */
@property NSInteger count;

/* IMPORTTANT */
@property CLLocationManager *locManager;

@property BOOL hasConnection;
@property BNNCustomer *customer;

@property NSDate *lastOpenDoorTime;

@end

@implementation BNNHotelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             username:(NSString *)username
             password:(NSString *)password {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.count=0;
      self.hasConnection=false;
      self.lastOpenDoorTime = nil;
      
      self.locManager = [[CLLocationManager alloc] init];
      [self.locManager setDelegate:self];
      
      self.customer = [[BNNCustomer alloc] initWithUsername:username password:password];
      self.customer.cdelegate = self;
      
    }
    return self;
}

- (void)updateUserInfo {
  [self.userinfoLabel setText:[self.customer userInfoString]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Do any additional setup after loading the view from its nib.
  [self.userinfoLabel setText:[self.customer userInfoString]];
  
  [self setCheckInButtonEnabled:([self.customer canCheckIn] && self.hasConnection)];
  
  if([CLLocationManager isRangingAvailable]){
    [self.locManager startMonitoringForRegion:self.customer.hotelBeaconRegion];
    
    [self.locManager startRangingBeaconsInRegion:self.customer.hotelBeaconRegion];
    [self.locManager startRangingBeaconsInRegion:self.customer.roomBeaconRegion];
  }
}

#pragma mark - Actions

- (IBAction)checkInPressed:(id)sender {
  if([self.checkInButton.titleLabel.text isEqualToString:@"Check In"]){
    [self.customer checkIn];
  }else if([self.checkInButton.titleLabel.text isEqualToString:@"Check Out"]){
    [self.customer checkOut];
  }
}


- (void)setCheckInState:(BOOL)success{
  if(success){
    [self.checkInButton setTitle:@"Check Out" forState:UIControlStateNormal];
    [self.checkInButton setEnabled:[self.customer canCheckOut]];
    [self.hotelinfoLabel setText:@"Checked in successfully."];
  }else{
    [self.hotelinfoLabel setText:@"Check in failed."];
    [self.checkInButton setEnabled:false];
  }
}

- (void)setCheckOutState:(BOOL)success{
  if(success){
    [self.checkInButton setTitle:@"Check In" forState:UIControlStateNormal];
    [self.checkInButton setEnabled:[self.customer canCheckIn]];
    [self.hotelinfoLabel setText:@"Checked out successfully."];
  }else{
    [self.hotelinfoLabel setText:@"Check out failed."];
    [self.checkInButton setEnabled:false];
  }
}

- (IBAction)signOutPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  if([self.customer canCheckIn])
    [self scheduleNotificationWithText:@"Entered hotel region, please check in."];
  NSLog(@"Entered hotel region, please check in.");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
  self.hasConnection = false;
  [self setCheckInButtonEnabled:NO];
  //[self scheduleNotificationWithText:@"exit region"];
  NSLog(@"Exited region...");
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
  // Return if no beacon detected.
  if ([beacons count] <= 0) { return; }
  CLBeacon *nearestExhibit = [beacons firstObject];
  CLProximity proximity = nearestExhibit.proximity;

  if(proximity == CLProximityNear){
    if(DEBUG){
      NSString *info=[NSString stringWithFormat:@"Distance: near"];
      [self.locLabel setText:info];
      self.count++;
    }
    if(!self.hasConnection){
      if([self.checkInButton.titleLabel.text isEqualToString:@"Check In"]){
        [self setCheckInButtonEnabled:[self.customer canCheckIn]];
      }else if([self.checkInButton.titleLabel.text isEqualToString:@"Check Out"]){
        [self setCheckInButtonEnabled:[self.customer canCheckOut]];
      }
    }
    self.hasConnection = true;
    
    //[self scheduleNotificationWithText:@"a nearby beacon is detected"];
  }else if(proximity == CLProximityFar){
    if(DEBUG){
      NSString *info=[NSString stringWithFormat:@"Distance: far"];
      [self.locLabel setText:info];
      self.count++;
    }
    if(!self.hasConnection){
      if([self.checkInButton.titleLabel.text isEqualToString:@"Check In"]){
        [self setCheckInButtonEnabled:[self.customer canCheckIn]];
      }else if([self.checkInButton.titleLabel.text isEqualToString:@"Check Out"]){
        [self setCheckInButtonEnabled:[self.customer canCheckOut]];
      }
    }
    self.hasConnection = true;
  }else if (proximity == CLProximityImmediate) {
    if(DEBUG){
      NSString *info=[NSString stringWithFormat:@"Distance: immediate"];
      [self.locLabel setText:info];
      self.count++;
    }
    self.hasConnection = true;
    NSDate *currDate = [NSDate new];
    if(self.lastOpenDoorTime==nil){
      [self.customer unlockDoor];
    }else{
      NSTimeInterval diff = [currDate timeIntervalSinceDate:self.lastOpenDoorTime];
      if (diff>30) {
        [self.customer unlockDoor];
      }
    }
  }
}

#pragma mark - Helper functions

- (void)setCheckInButtonEnabled:(BOOL)enabled {
  if(enabled){
    [self.hotelinfoLabel setText:@"A hotel is detected."];
  }else{
    [self.hotelinfoLabel setText:@"No hotel detected."];
  }
  [self.checkInButton setEnabled:enabled];
}

- (void)scheduleNotificationWithText:(NSString *)text {
  NSDate *currDate = [NSDate date];
  
  UILocalNotification *localNotif = [[UILocalNotification alloc] init];
  if (localNotif == nil)
    return;
  localNotif.fireDate = currDate;
  localNotif.timeZone = [NSTimeZone defaultTimeZone];
  
  localNotif.alertBody = text;
  localNotif.alertAction = @"View details";
  
  localNotif.soundName = UILocalNotificationDefaultSoundName;
  
  NSDictionary *infoDict = [NSDictionary dictionaryWithObject:text forKey:@"AlertText"];
  localNotif.userInfo = infoDict;
  
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

@end
