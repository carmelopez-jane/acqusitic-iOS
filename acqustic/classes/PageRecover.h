//
//  PageRecover.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "SimpleEdit.h"

@interface PageRecover : Page <UITextFieldDelegate>{
}

@property (strong, nonatomic) IBOutlet SimpleEdit *seLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnRecover;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

@end
