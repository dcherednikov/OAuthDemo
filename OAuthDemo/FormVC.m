//
//  KeySecretVC.m
//  OAuthDemo
//
//  Created by Admin on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "FormVC.h"
#import "Coordinator.h"
#import "SpinnerView.h"
#import "MessageView.h"

typedef BOOL Direction;
#define UP YES
#define DOWN NO

@interface FormVC () <UITextFieldDelegate> {
 
    MessageView *messageView;
    SpinnerView *spinnerView;
    
    IBOutlet UITextField *consumerKeyField;
    IBOutlet UITextField *consumerSecretField;
    IBOutlet UITextField *requestURLField;
    IBOutlet UITextField *authorizationURLField;
    IBOutlet UITextField *accessURLField;
    
    NSArray<UITextField *> *allFields;
    
    IBOutlet NSLayoutConstraint *topConstraint;
    CGRect keyboardFrame;
    CGFloat keyboardAnimationDuration;
}

@end


@implementation FormVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    messageView = [[[NSBundle mainBundle] loadNibNamed:@"MessageView"
                                                 owner:nil
                                               options:nil] firstObject];
    messageView.containerView = self.view;
    spinnerView = [[[NSBundle mainBundle] loadNibNamed:@"SpinnerView"
                                                 owner:nil
                                               options:nil] firstObject];
    spinnerView.containerView = self.view;
    
    consumerKeyField.delegate = self;
    consumerSecretField.delegate = self;
    requestURLField.delegate = self;
    authorizationURLField.delegate = self;
    accessURLField.delegate = self;
    
    allFields = @[consumerKeyField,
                  consumerSecretField,
                  requestURLField,
                  authorizationURLField,
                  accessURLField];
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *frameValue = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardFrame = frameValue.CGRectValue;
    NSNumber *durationValue = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    keyboardAnimationDuration = durationValue.doubleValue;
    NSLog(@"%@", notification);
    [self animateView:UP];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *durationValue = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    keyboardAnimationDuration = durationValue.doubleValue;
    NSLog(@"%@", notification);
    [self animateView:DOWN];
}

#pragma mark - animations

- (void)animateView:(Direction)direction {

    CGFloat targetConstant = 0.f;
    if (direction == UP) {
        
        targetConstant = -keyboardFrame.size.height/2.f;
    }
    [UIView animateWithDuration:keyboardAnimationDuration
                     animations:^{
                         
                         topConstraint.constant = targetConstant;
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - IBActions

- (IBAction)startButtonTapped:(id)sender {

    _consumerKeyFieldText = consumerKeyField.text;
    _consumerSecretFieldText = consumerSecretField.text;
    _requestURLFieldText = requestURLField.text;
    _authorizationURLFieldText = authorizationURLField.text;
    _accessURLFieldText = accessURLField.text;
    
    BOOL hasEmptyField = NO;
    for (UITextField *field in allFields) {
        
        BOOL currentFieldIsEmpty = !field.text || [field.text isEqualToString:@""];
        hasEmptyField = hasEmptyField || currentFieldIsEmpty;
    }
    if (hasEmptyField) {
        
        [messageView appearWithMessage:@"all fields must be filled"];
        [self.view endEditing:YES];
    }
    else {
        
        [_coordinator onAuthorizationRequested];
    }
}

#pragma mark - public

- (void)setConsumerKeyFieldText:(NSString *)text {
    
    if (text || ![text isEqualToString:@""]) {
     
        consumerKeyField.text = text;
    }
}

- (void)setConsumerSecretFieldText:(NSString *)text {
    
    if (text || ![text isEqualToString:@""]) {

        consumerSecretField.text = text;
    }
}

- (void)setRequestURLFieldText:(NSString *)text {
    
    if (text || ![text isEqualToString:@""]) {

        requestURLField.text = text;
    }
}

- (void)setAuthorizationURLFieldText:(NSString *)text {
    
    if (text || ![text isEqualToString:@""]) {

        authorizationURLField.text = text;
    }
}

- (void)setAccessURLFieldText:(NSString *)text {
    
    if (text || ![text isEqualToString:@""]) {

        accessURLField.text = text;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == consumerKeyField) {
        
        _consumerKeyFieldText = textField.text;
    }
    else if (textField == consumerSecretField) {
        
        _consumerSecretFieldText = textField.text;
    }
    else if (textField == requestURLField) {
        
        _requestURLFieldText = textField.text;
    }
    else if (textField == authorizationURLField) {
        
        _authorizationURLFieldText = textField.text;
    }
    else if (textField == accessURLField) {
        
        _accessURLFieldText = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - Messaging

- (void)askToWait {
    
    [spinnerView appearWithMessage:@"first token and token secret\nare requested..."];
    [self.view endEditing:YES];
}

- (void)stopWaiting {
    
    [spinnerView disappear];
}

- (void)informOnFailure {
    
    [messageView appearWithMessage:@"first request failed"];
}

@end
