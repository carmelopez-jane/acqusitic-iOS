//
//  HeaderSearch.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface HeaderSearch : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *vSearch;
@property (strong, nonatomic) IBOutlet UIView *vFilters;
@property (strong, nonatomic) IBOutlet UITextField * tfSearch;
@property (strong, nonatomic) IBOutlet UIView *vClear;

-(void) prepareForInterfaceBuilder;

@end
