//
//  BNNCustomer.h
//  iHotel
//
//  Created by Lirong Yuan on 4/8/14.
//  Copyright (c) 2014 Banana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol BNNCustomerDelegate <NSObject>

- (void)updateUserInfo;
- (void)setCheckInState:(BOOL)success;
- (void)setCheckOutState:(BOOL)success;

@end

@interface BNNCustomer : NSObject

@property CLBeaconRegion *hotelBeaconRegion;
@property CLBeaconRegion *roomBeaconRegion;
@property (weak, atomic) NSObject<BNNCustomerDelegate> *cdelegate;

- (NSString *)checkValidUserWithUsername:(NSString *)uname
                                password:(NSString *)pword;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

- (NSString *)userInfoString;

- (BOOL)checkIn;
- (BOOL)unlockDoor;
- (BOOL)checkOut;

- (BOOL)canCheckIn;

- (BOOL)canCheckOut;

@end
