//
//  PagePortada.h
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"

@interface PagePortada : Page {
    BOOL done;
}

@property (strong, nonatomic) IBOutlet UILabel *lblVersion;
@property (strong, nonatomic) IBOutlet UIImageView *ivLogo;

@end
