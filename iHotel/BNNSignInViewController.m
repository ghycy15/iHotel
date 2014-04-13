//
//  BNNSignInViewController.m
//  iHotel
//
//  Created by Lirong Yuan on 4/8/14.
//  Copyright (c) 2014 Banana. All rights reserved.
//

#import "BNNSignInViewController.h"
#import "BNNHotelViewController.h"
#include "BNNCustomer.h"

@interface BNNSignInViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property BNNHotelViewController *hotelController;

@end

@implementation BNNSignInViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
  }
  return self;
}

- (IBAction)signInPressed:(id)sender {
  // check if username and password is valid
  NSString *username = [_usernameTextField text];
  NSString *password = [_passwordTextField text];
  if([username isEqualToString:@"gu"]&&[password isEqualToString:@"0000"]){
    self.hotelController = [[BNNHotelViewController alloc]
        initWithNibName:@"BNNHotelViewController"
                 bundle:[NSBundle mainBundle]
               username:username
               password:password];
    [self presentViewController:self.hotelController animated:YES completion:nil];
  }else{
    [NSThread sleepForTimeInterval:0.2];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid username or password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
  }
}

- (IBAction)cancelPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(buttonIndex == 0){ // cancel button
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
  }else if (buttonIndex==1){ // try again button
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
  }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
