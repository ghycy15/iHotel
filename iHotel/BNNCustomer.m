//
//  BNNCustomer.m
//  iHotel
//
//  Created by Lirong Yuan on 4/8/14.
//  Copyright (c) 2014 Banana. All rights reserved.
//

#import "BNNCustomer.h"

@interface BNNCustomer() <NSStreamDelegate>

@property NSInteger state;
/* 0: waiting for info
   1: success
   2: fail */

@property NSString *uuidString;

@property NSString *username;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *email;

@property NSString *hotelName;
@property NSString *roomName;

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;

@property NSDate *lastOperationTime;

@property BOOL checkedin;
@property BOOL checkedout;

@end

@implementation BNNCustomer

+ (NSString *)getUUIDWithUsername:(NSString *)uname {
  return @"24B3ECD0-A986-11E3-A5E2-0800200C9A66";
}

- (id)initWithUsername:(NSString *)username
              password:(NSString *)password {
  self = [super init];
  if (self) {
    self.state = 0;
    self.username = username;
    self.lastOperationTime = nil;
    self.uuidString = [BNNCustomer getUUIDWithUsername:username];
    
    self.checkedin = NO;
    self.checkedout = NO;
    
    [self initNetworkCommunication];
    [self checkValidUserWithUsername:username password:password];
    [self loadUserInfo];
  }
  return self;
}

- (NSString *)checkValidUserWithUsername:(NSString *)uname
                                password:(NSString *)pword {
  NSString *response  = [NSString stringWithFormat:@"app:;:login:;:%@:;:%@\n",uname,pword];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  return nil;
}

- (void)initNetworkCommunication {
  CFReadStreamRef readStream;
  CFWriteStreamRef writeStream;
  CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"guhuyue.com", 10022, &readStream, &writeStream);
  self.inputStream = (__bridge NSInputStream *)readStream;
  self.outputStream = (__bridge NSOutputStream *)writeStream;
  [self.inputStream setDelegate:self];
  [self.outputStream setDelegate:self];
  [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
  [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
  [self.inputStream open];
  [self.outputStream open];
}

- (void)loadUserInfo {
  if([self.username isEqualToString:@"gu"]){
    self.firstName = @"Huyue";
    self.lastName = @"Gu";
    self.email = @"guhuyue@gmail.com";
    
    self.hotelName = @"";
    self.roomName = @"";
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:self.uuidString];
    CLBeaconMajorValue majorValue = 1;
    
    self.hotelBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
        major:majorValue minor:0 identifier:@"com.banana.iHotel"];
    self.hotelBeaconRegion.notifyEntryStateOnDisplay = YES;
    
    self.roomBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
        major:majorValue minor:1 identifier:@"com.banana.iHotel"];
    self.roomBeaconRegion.notifyEntryStateOnDisplay = YES;
  }
}

- (BOOL)checkIn {
  if(self.checkedin){return false;}

  NSString *response  = [NSString stringWithFormat:@"app:;:gu:;:24B3ECD0-A986-11E3-A5E2-0800200C9A66:;:0001:;:0000:;:checkin\n"];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  return YES;
}

- (BOOL)unlockDoor {
  if(!self.checkedin){return NO;}
  
  NSDate *now = [[NSDate alloc] init];
  if(self.lastOperationTime!=nil){
    NSTimeInterval diff = [now timeIntervalSinceDate:self.lastOperationTime];
    NSLog(@"%g",diff);
    if(diff<15){return NO;}
  }
  NSString *response  = [NSString stringWithFormat:@"app:;:gu:;:24B3ECD0-A986-11E3-A5E2-0800200C9A66:;:0001:;:0001:;:immediate\n"];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  self.lastOperationTime = now;
  return YES;
}

- (BOOL)checkOut {
  if(self.checkedout){return false;}
  NSString *response  = [NSString stringWithFormat:@"app:;:gu:;:24B3ECD0-A986-11E3-A5E2-0800200C9A66:;:0001:;:0000:;:checkout\n"];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  return YES;
}

- (BOOL)canCheckIn {
  if(self.checkedin)return NO;
  NSString *response  = [NSString stringWithFormat:@"app:;:gu:;:24B3ECD0-A986-11E3-A5E2-0800200C9A66:;:0001:;:0000:;:far\n"];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  return YES;
}

- (BOOL)canCheckOut {
  if(self.checkedout)return NO;
  
  NSString *response  = [NSString stringWithFormat:@"app:;:gu:;:24B3ECD0-A986-11E3-A5E2-0800200C9A66:;:0001:;:0000:;:cancheckout\n"];
  NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
  [self.outputStream write:[data bytes] maxLength:[data length]];
  return YES;
}

#pragma mark - Display functions
- (NSString *)userInfoString {
  NSString *info = [NSString stringWithFormat:
      @"    User:\t\t%@ %@\n    Hotel:\t%@\n    Room:\t%@\n",
      self.firstName, self.lastName, self.hotelName, self.roomName];
  return info;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
  
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
      if(theStream == self.inputStream) {
        NSLog(@"Input Stream opened");
      }
      if(theStream == self.outputStream) {
        NSLog(@"Output Stream opened");
      }
			break;
      
		case NSStreamEventHasBytesAvailable:
      if (theStream == self.inputStream) {
        uint8_t buffer[1024];
        long len;
        while ([self.inputStream hasBytesAvailable]) {
          len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
          if (len > 0) {
            NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
            if (output != nil) {
              NSLog(@"Server said: %@", output);
              NSArray *listItems = [output componentsSeparatedByString:@":;:"];
              if([listItems count]==1){
                if([output isEqualToString:@"SUCCESS"]){
                  self.state = 1;
                }else if([output isEqualToString:@"FAIL"]){
                  self.state = 2;
                }else if([output isEqualToString:@"NoAction"]){
                  
                }else if([output isEqualToString:@"checkout"]){
                  
                }else if([output isEqualToString:@"OPEN"]){
                  
                }
              }else if([listItems count]==2){
                NSString *item1=listItems[0],*item2=listItems[1];
                if([item1 isEqualToString:@"checkin"]){
                  // checkin:;:roomnumber
                  self.roomName = item2;
                  self.checkedin = YES;
                  self.checkedout = NO;
                  [self.cdelegate updateUserInfo];
                  [self.cdelegate setCheckInState:YES];
                }else if ([item1 isEqualToString:@"checkout"]){
                  self.roomName = @"";
                  self.checkedout = YES;
                  self.checkedin = NO;
                  [self.cdelegate updateUserInfo];
                  [self.cdelegate setCheckOutState:YES];
                }
              }else if([listItems count]==3){
                NSString *item1=listItems[0],*item2=listItems[1];
                if([item1 isEqualToString:@"checkin"]){
                  // checkin:;:Hotel Name:;:Hotel information
                  self.hotelName = item2;
                  [self.cdelegate updateUserInfo];
                }
              }
            }
          }
        }
      }
			break;
      
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
      
		case NSStreamEventEndEncountered:
      NSLog(@"Connection ended!");
      [theStream close];
      [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			break;
    
    case NSStreamEventHasSpaceAvailable:
      NSLog(@"Space available!");
      break;
      
    case NSStreamEventNone:
      NSLog(@"Event None.");
      break;
      
		default:
			NSLog(@"Unknown event");
	}
  
}

@end
