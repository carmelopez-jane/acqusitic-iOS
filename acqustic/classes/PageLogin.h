//
//  PageLogin.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "SimpleEdit.h"
#import "PasswordEdit.h"

@interface PageLogin : Page <UITextFieldDelegate> {
}

@property (strong, nonatomic) IBOutlet UIImageView *ivLogo;
@property (strong, nonatomic) IBOutlet UILabel *lblLogo;
@property (strong, nonatomic) IBOutlet UIScrollView *vContent;

@property (strong, nonatomic) IBOutlet SimpleEdit *seLogin;
@property (strong, nonatomic) IBOutlet PasswordEdit *pePassword;
@property (strong, nonatomic) IBOutlet UIButton * btnLogin;
@property (strong, nonatomic) IBOutlet UIButton * btnRegister;
@property (strong, nonatomic) IBOutlet UILabel *lblExplore;
@property (strong, nonatomic) IBOutlet UILabel *lblRecover;




@end
