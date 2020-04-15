//
//  PageRegister.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "SimpleEdit.h"
#import "PasswordEdit.h"

@interface PageRegister : Page <UITextFieldDelegate, UITextViewDelegate>{
}

@property (strong, nonatomic) IBOutlet UIScrollView *vContent;
@property (strong, nonatomic) IBOutlet UIView *vAll;
@property (strong, nonatomic) IBOutlet SimpleEdit *seName;
@property (strong, nonatomic) IBOutlet SimpleEdit *seSurname;
@property (strong, nonatomic) IBOutlet SimpleEdit *seLogin;
@property (strong, nonatomic) IBOutlet SimpleEdit *seProvince;
@property (strong, nonatomic) IBOutlet PasswordEdit *pePassword;
@property (strong, nonatomic) IBOutlet SimpleEdit *seGroup;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UISwitch *swTerms;
@property (strong, nonatomic) IBOutlet UILabel *lblTerms;
@property (strong, nonatomic) IBOutlet UITextView *tvTerms;


@end
