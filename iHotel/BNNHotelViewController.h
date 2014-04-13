//
//  BNNHotelViewController.h
//  iHotel
//
//  Created by Lirong Yuan on 4/8/14.
//  Copyright (c) 2014 Banana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface BNNHotelViewController : UIViewController

/* IBOUTLET */
@property (weak, nonatomic) IBOutlet UILabel *hotelinfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UILabel *userinfoLabel;

/* OTHERS */
@property (strong, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *locLabel;

/* FUNCTIONS */
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             username:(NSString *)username
             password:(NSString *)password;

@end
