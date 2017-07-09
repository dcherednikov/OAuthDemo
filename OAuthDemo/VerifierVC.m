//
//  VerifierVC.m
//  OAuthDemo
//
//  Created by Admin on 09/07/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "VerifierVC.h"

@interface VerifierVC () <UITextFieldDelegate> {
    
    IBOutlet UITextField *verifierTextField;
}

@end


@implementation VerifierVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    verifierTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden = NO;
}

- (IBAction)verifierProvidedButtonPressed:(id)sender {
    
    [_coordinator onVerifierInfoProvided:verifierTextField.text];
}

- (IBAction)verifierNotProvidedButtonPressed:(id)sender {
    
    [_coordinator onVerifierInfoProvided:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self verifierProvidedButtonPressed:nil];
    return YES;
}


@end
