//
//  OCLoginViewController.m
//  KLoginManager
//
//  Created by Patrick on 20/02/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

#import "OCLoginViewController.h"
#import "NBPhoneNumberUtil.h"
#import "MBProgressHUD.h"
#import "NSString+OrchardMapping.h"
#import "OGLCoreDataMapper.h"
#import <Krake/Krake-Swift.h>
@import LaserFloatingTextField;


@interface OCLoginViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate>
{
    id openObserver;
    id closeObserver;
    NSDictionary *mainParams;
    NSMutableDictionary *responseType;
    NSArray *policies;
    UIInterfaceOrientationMask orientationMask;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIStackView *loginMainStackView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *baseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *policiesTableHeight;

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *loginWithLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerx;

@property (weak, nonatomic) IBOutlet UIStackView *socialToolbar;

@property (weak, nonatomic) IBOutlet EGFloatingTextField *username;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *password;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *lostPassword;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

//registerView
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *registrationLabel;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *usernameRegistration;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *passwordRegistration;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *confirmRegistration;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *numberRegistration;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;


//LOST PASSWORD
@property (weak, nonatomic) IBOutlet UIView *lostpwdView;
@property (weak, nonatomic) IBOutlet UIButton *recoverButton;
@property (weak, nonatomic) IBOutlet UILabel *lostPasswordLabel;
@property (weak, nonatomic) IBOutlet EGFloatingTextField *emailsmsTextField;

@end

@implementation OCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.registerButton setEnabled: false];
    
    self.closeButton.clipsToBounds = YES;
    self.closeButton.layer.cornerRadius = 22.0;
    [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.closeButton setImage:[UIImage imageNamed:@"scroll_bottom" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.backButton.clipsToBounds = YES;
    self.backButton.layer.cornerRadius = 22.0;
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backButton setImage:[UIImage imageNamed:@"indietro" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.backButton.alpha = 0.0;
    
    self.loginWithLabel.text = [@"LOGIN" localizedString];
    
    if(!Login.canUserCancelLogin)
    {
        self.closeButton.hidden = true;
    }
    
    if (!Login.canUserLoginWithKrake)
    {
        [self.username setHidden:true];
        [self.password setHidden:true];
        [self.lostPassword setHidden:true];
        [self.registerButton setHidden:true];
    }
    else
    {
        [self loadRegisterData];
        
        self.username.IBPlaceholder = NSLocalizedStringWithDefaultValue(@"e_mail", nil, [NSBundle mainBundle], [@"e_mail" localizedString], "");
        self.password.IBPlaceholder = [@"password" localizedString];
        self.usernameRegistration.IBPlaceholder = NSLocalizedStringWithDefaultValue(@"e_mail", nil, [NSBundle mainBundle], [@"e_mail" localizedString], "");
        self.passwordRegistration.IBPlaceholder = [@"password" localizedString];
        self.confirmRegistration.IBPlaceholder = [@"confirm_password" localizedString];
        self.numberRegistration.IBPlaceholder = [@"phone_number" localizedString];

        self.registrationLabel.text = [@"Registration" localizedString];
        
        [self.lostPassword setTitle:[@"lost_pwd" localizedString] forState:UIControlStateNormal];
        [self.registerButton setTitle:[@"Registration" localizedString] forState:UIControlStateNormal];
        [self.loginButton setTitle:[@"Login" localizedString] forState:UIControlStateNormal];
        [self.registrationButton setTitle:[@"Register" localizedString] forState:UIControlStateNormal];

        self.lostPasswordLabel.text = [@"lost_pwd" localizedString];
        if (Login.canUserRecoverPasswordWithSMS){
            self.emailsmsTextField.IBPlaceholder = [@"placeholder_sms_or_mail_restore_password" localizedString];
        }else{
            self.emailsmsTextField.IBPlaceholder = [@"placeholder_mail_restore_password" localizedString];
        }
        if (!Login.userHaveToRegisterWithSMS){
            [self.numberRegistration setHidden:true];
        }
        [self.recoverButton setTitle:[@"Recover_password" localizedString] forState:UIControlStateNormal];
    }
    
    self.view.backgroundColor = [KTheme.login color:KLoginColorTypeBackground];
    self.baseView.effect = [UIBlurEffect effectWithStyle:KTheme.login.centerViewStyle];
    
    [[KTheme login] applyThemeToImageView:self.backgroundImageView];
    
    [[KTheme login] applyThemeTo:self.username];
    [[KTheme login] applyThemeTo:self.password];
    [[KTheme login] applyThemeTo:self.usernameRegistration];
    [[KTheme login] applyThemeTo:self.passwordRegistration];
    [[KTheme login] applyThemeTo:self.confirmRegistration];
    [[KTheme login] applyThemeTo:self.numberRegistration];
    [[KTheme login] applyThemeTo:self.emailsmsTextField];
    
    [[KTheme login] applyThemeTo:self.closeButton style:KLoginButtonStyleClose];
    [[KTheme login] applyThemeTo:self.backButton style:KLoginButtonStyleBack];
    
    [[KTheme login] applyThemeTo:self.lostPassword style:KLoginButtonStyleSmall];
    [[KTheme login] applyThemeTo:self.registerButton style:KLoginButtonStyleSmall];
    [[KTheme login] applyThemeTo:self.loginButton style:KLoginButtonStyleDefault];
    [[KTheme login] applyThemeTo:self.registrationButton style:KLoginButtonStyleDefault];
    [[KTheme login] applyThemeTo:self.recoverButton style:KLoginButtonStyleDefault];

    [[KTheme login] applyThemeToTitle:self.registrationLabel];
    [[KTheme login] applyThemeToTitle:self.loginWithLabel];
    [[KTheme login] applyThemeToTitle:self.lostPasswordLabel];

    BOOL registerWithKrake = Login.canUserRegisterWithKrake;

    [self.registerButton setHidden:!registerWithKrake];
    [self.registerButton setEnabled:registerWithKrake];

    BOOL recoverPassword = Login.canUserRecoverPassword;

    [self.lostPassword setHidden:!recoverPassword];
    [self.lostPassword setEnabled:recoverPassword];
    
    NSArray<Class<KLoginProviderProtocol>> * items;
    items = [[KLoginManager shared] socials];
    for (Class<KLoginProviderProtocol> item in items) {
        UIStackView *rightStackView;
        if (@available(iOS 13.0, *)) {
            if (item == [AppleIDSignIn class])
            {
                rightStackView = self.loginMainStackView;
            }
            else
            {
                rightStackView = self.socialToolbar;
            }
        } else {
            rightStackView = self.socialToolbar;
        }
        [rightStackView addArrangedSubview:[[item shared] getLoginView]];
    }
    if ([self.socialToolbar.arrangedSubviews count] == 0 ){
        self.socialToolbar.hidden = true;
    }
    
    self.baseView.layer.cornerRadius = 10.0;
    self.baseView.clipsToBounds = true;
    
    self.tableView.scrollEnabled = true;
    
    if (@available(iOS 13.0, *)) {
        self.presentationController.delegate = self;
//        [self setModalInPresentation:true];
    }
}

-(BOOL)prefersStatusBarHidden{
    return true;
}

-(BOOL) isLightColor:(UIColor*)clr {
    CGFloat white = 0;
    [clr getWhite:&white alpha:nil];
    return (white >= 0.2);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    orientationMask = [(OGLAppDelegate*)[[UIApplication sharedApplication] delegate] lockInterfaceOrientationMask];
    [(OGLAppDelegate*)[[UIApplication sharedApplication] delegate] setLockInterfaceOrientationMask: UIInterfaceOrientationMaskPortrait];
    openObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.3 animations:^{
            //TODO: gestire allineamento tastiera
        
            if (self.registerView.isHidden){
                for (UIView *subV in self.loginView.subviews[0].subviews){
                    if ([subV isFirstResponder]){
                        self.centerx.constant = -subV.frame.origin.y/2;
                        break;
                    }
                }
            }else{
                for (UIView *subV in self.registerView.subviews[0].subviews){
                    if ([subV isFirstResponder]){
                        self.centerx.constant = -subV.frame.origin.y/2;
                        break;
                    }
                }
            }
            [self.view layoutIfNeeded];
        }];
    }];
    
    closeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.3 animations:^{
            self.centerx.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }];
    
    NSString *numero = [[NSUserDefaults standardUserDefaults] stringForConstantKey:OMStringConstantKeyUserPhoneNumber];
    if (numero.length > 0)
    {
        (void)[self.numberRegistration becomeFirstResponder];
        self.numberRegistration.text = numero;
        (void)[self.numberRegistration resignFirstResponder];
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForConstantKey:OMStringConstantKeyUserEmail];
    if (email.length > 0){
        (void)[self.username becomeFirstResponder];
        self.username.text = email;
        (void)[self.username resignFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:openObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:closeObserver];
    openObserver = nil;
    closeObserver = nil;
    
    [(OGLAppDelegate*)[[UIApplication sharedApplication] delegate] setLockInterfaceOrientationMask: orientationMask];
}

-(void)loadRegisterData{
    responseType = [[NSMutableDictionary alloc] init];
    
    [[KNetworkManager defaultManager: true checkHeaderResponse:false] policiesRegistration:^(BOOL success, id response, NSError *error) {
        if (success){
            self->policies = response;
            NSMutableArray *policyAnswers = [[NSMutableArray alloc] init];
            for (NSDictionary *policy in self->policies){
                [policyAnswers addObject: [[NSMutableDictionary alloc] initWithDictionary: @{
                                            @"PolicyId": policy[@"PolicyId"],
                                            @"UserHaveToAccept": policy[@"UserHaveToAccept"],
                                            @"PolicyAnswer": @(FALSE)
                                            }]
                 ];
            }
            self->responseType[@"PolicyAnswers"] = policyAnswers;
            self.policiesTableHeight.constant = self.tableView.rowHeight * self->policies.count;
            [self.tableView reloadData];
        }else{
            if (error){
                [[KLoginManager shared] showMessage:error.localizedDescription withType:ModeError];
            }
        }
    }];
}

-(IBAction)registerNewUser:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NSString *number = self.numberRegistration.text;
    if (number != nil){
        if ([number hasPrefix:@"00"]) {
            number = [@"+" stringByAppendingString:[number substringFromIndex:2]];
        }
        if (![number hasPrefix:@"+"]) {
            number = [@"+39" stringByAppendingString:number];
        }
    }
    NBPhoneNumber *myNumber = [phoneUtil parseWithPhoneCarrierRegion:number error:&anError];
    if ([phoneUtil isValidNumber:myNumber] || !Login.userHaveToRegisterWithSMS) {
        NSString *nationalNumber = nil;
        NSString *countryCode = [NSString stringWithFormat:@"%@",[phoneUtil extractCountryCode:number nationalNumber:&nationalNumber]];
        nationalNumber = [nationalNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        responseType[@"Email"] = self.usernameRegistration.text;
        responseType[@"Username"] = self.usernameRegistration.text;
        responseType[@"Password"] = self.passwordRegistration.text;
        responseType[@"ConfirmPassword"] = self.confirmRegistration.text;
        responseType[@"Culture"] = [KConstants currentLanguage];
        [[KNetworkManager defaultManager:true checkHeaderResponse:true] krakeRegisterUser:responseType completion:^(BOOL success, NSDictionary * _Nullable response, NSError * _Nullable message) {
            if (success) {
                [[NSUserDefaults standardUserDefaults] setStringAndSync:self.usernameRegistration.text forConstantKey:OMStringConstantKeyUserEmail];
                [[NSUserDefaults standardUserDefaults] setStringAndSync:self.usernameRegistration.text forConstantKey:OMStringConstantKeyUserName];
                if (nationalNumber.length>3 && countryCode>0) {
                    [[KNetworkManager defaultManager:true checkHeaderResponse:false] updateUserProfile:@{@"UserPwdRecoveryPart.InternationalPrefix" : countryCode, @"UserPwdRecoveryPart.PhoneNumber" : nationalNumber} completion:^(BOOL success, id responseObject, NSError *error) {
                        [[NSUserDefaults standardUserDefaults] setStringAndSync:number forConstantKey:OMStringConstantKeyUserPhoneNumber];
                        [[KLoginManager shared] makeCompletion:success response:response error:message];
                    }];
                    
                }else{
                    [[KLoginManager shared] makeCompletion:success response:response error:message];
                }
            }
            else {
                if ([message code] == 1003) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                                    message:message.localizedDescription
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:
                     [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
                        [self closeRegisterView:nil];
                    }]];
                    [self showViewController:alert sender:nil];
                }
                else if (message){
                    [[KLoginManager shared] showMessage:message.localizedDescription withType:ModeError];
                }
            }
            [MBProgressHUD hideHUDForView:self.view animated:true];
        }];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:true];
        [[KLoginManager shared] showMessage:[@"sms_not_valid" localizedString] withType:ModeError];
    }
}

-(IBAction)dismissKeyBoard:(id)sender{
    (void)[self.username resignFirstResponder];
    (void)[self.password resignFirstResponder];
    (void)[self.usernameRegistration resignFirstResponder];
    (void)[self.passwordRegistration resignFirstResponder];
    (void)[self.confirmRegistration resignFirstResponder];
    (void)[self.numberRegistration resignFirstResponder];
    (void)[self.emailsmsTextField resignFirstResponder];
}

-(IBAction)closeMe:(id)sender{
    [[KLoginManager shared] userClosePresentedLoginViewController];
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)loginToOrchard:(id)sender{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"Username"] = self.username.text;
    params[@"Password"] = self.password.text;

    //TODO: verificare e pensare una soluzione per gli accessi social
    [[NSUserDefaults standardUserDefaults] setStringAndSync:self.username.text forConstantKey:OMStringConstantKeyUserEmail];

    [[KLoginManager shared] objc_loginWith:[KrakeAuthenticationProvider orchard] params:params saveTokenParams: false];
}

-(IBAction)openRegisterView:(id)sender{
    self.loginView.hidden = true;
    self.lostpwdView.hidden = true;
    self.registerView.hidden = false;
    [UIView animateWithDuration:0.5 animations:^{
        self.backButton.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)openLostpwdView:(id)sender{
    self.loginView.hidden = true;
    self.registerView.hidden = true;
    self.lostpwdView.hidden = false;
    [UIView animateWithDuration:0.5 animations:^{
        self.backButton.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)closeRegisterView:(id)sender{
    
    self.registerView.hidden = true;
    self.lostpwdView.hidden = true;
    self.loginView.hidden = false;
    [UIView animateWithDuration:0.5 animations:^{
        self.backButton.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)requestLostPassword:(id)sender{
    [self openLostpwdView:nil];
}

-(IBAction)userRequestLostPassword:(id)sender{
    
    NSString *emailRegEx = @"^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    BOOL result = [predicate evaluateWithObject:self.emailsmsTextField.text];
    if (result){
        [[KLoginManager shared] callRequestPasswordLostWithQueryString:@"RequestLostPasswordAccountOrEmailSsl" params:@{@"username" : self.emailsmsTextField.text}];
        [self closeRegisterView:nil];
    }else{
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        NSString *number = self.emailsmsTextField.text;
        if ([number hasPrefix:@"00"]) {
            number = [@"+" stringByAppendingString:[number substringFromIndex:2]];
        }
        if (![number hasPrefix:@"+"]) {
            number = [@"+39" stringByAppendingString:number];
        }
        NBPhoneNumber *myNumber = [phoneUtil parseWithPhoneCarrierRegion:number error:&anError];
        if ([phoneUtil isValidNumber:myNumber]) {
            NSString *nationalNumber = nil;
            NSNumber *countryCode = [phoneUtil extractCountryCode:number nationalNumber:&nationalNumber];
            nationalNumber = [nationalNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            mainParams = @{ @"phoneNumber" : @{@"internationalPrefix": [NSString stringWithFormat:@"%@", countryCode], @"phoneNumber" : nationalNumber}};
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:KInfoPlist.appName message:[NSString stringWithFormat:@"%@ +%@ %@", [@"check_your_number" localizedString], countryCode, nationalNumber] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:[@"Cancel" localizedString] style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:[@"OK" localizedString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self->mainParams){
                    [[KLoginManager shared] callRequestPasswordLostWithQueryString:@"RequestLostPasswordSmsSsl" params:[self->mainParams copy]];
                    self->mainParams = nil;
                    [self closeRegisterView:nil];
                }else{
                    [[KLoginManager shared] showMessage:[@"empty_field" localizedString] withType:ModeError];
                }
            }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:true completion:nil];
            });
        }else{
            [[KLoginManager shared] showMessage:[@"sms_not_valid" localizedString] withType:ModeError];
        }
    }
    
}


//MARK: - UITextField DELEGATE

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameRegistration)
    {
        (void)[self.passwordRegistration becomeFirstResponder];
    }
    else if(textField == self.passwordRegistration)
    {
        (void)[self.confirmRegistration becomeFirstResponder];
    }
    else if(textField == self.confirmRegistration && self.numberRegistration.superview != nil)
    {
        (void)[self.numberRegistration becomeFirstResponder];
    }
    else if(textField == self.username)
    {
        (void)[self.password becomeFirstResponder];
    }
    else if(textField == self.password)
    {
        [self loginToOrchard:self.loginButton];
    }
    else
    {
        [self.view endEditing:true];
    }
    return true;
}

#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return policies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = [policies objectAtIndex:indexPath.row];
    cell.textLabel.text = dic[@"Title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    UISwitch *switcher = [[UISwitch alloc] init];
    switcher.tag = indexPath.row;
    [switcher setOn: NO];
    [switcher addTarget:self action:@selector(changeValueSwitcher:) forControlEvents:UIControlEventValueChanged];
    [[KTheme currentObjc] applyThemeToSwitch:switcher style:SwitchStyleLogin];
    cell.accessoryView = switcher;
    if ([dic[@"UserHaveToAccept"] integerValue] == 1)
        cell.detailTextLabel.text = [@"required" localizedString];
    else
        cell.detailTextLabel.text = nil;
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = [policies objectAtIndex:indexPath.row];
    
    [self presentPolicyViewControllerWithPolicyEndPoint:nil policyTitle:dic[@"Title"] policyText:dic[@"Body"] largeMargin:true];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)changeValueSwitcher:(UISwitch*)switcher{
    NSUInteger index = switcher.tag;
    NSDictionary *policyEdited = [policies objectAtIndex:index];
    for (NSMutableDictionary *policy in responseType[@"PolicyAnswers"]) {
        if ([policyEdited[@"PolicyId"] longValue] == [policy[@"PolicyId"] longValue]) {
            policy[@"PolicyAnswer"] = [NSNumber numberWithBool:switcher.on];
        }
    }
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    [[KLoginManager shared] userClosePresentedLoginViewController];
}
@end
