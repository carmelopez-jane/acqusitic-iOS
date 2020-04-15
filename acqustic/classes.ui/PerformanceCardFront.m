//
//  PerformanceCardFront.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PerformanceCardFront.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "NSAttributedString+DDHTML.h"

@implementation PerformanceCardFront

@synthesize contentView, lblTitle;
@synthesize perf;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    return self;
}

-(void)internalInit {
    NSBundle * bundle = [NSBundle bundleForClass:self.class];
    if (bundle) {
        [bundle loadNibNamed:@"PerformanceCardFront" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(CGFloat) setPerformance:(Performance *)perf {
    self.lblTitle.text = perf.name;
    NSString * date = [Utils formatDate:(long)perf.performance_date withFormat:@"EEEE d MMM"];
    self.lblDetail.text = [NSString stringWithFormat:@"%@\n%@", date, perf.provisional_location];
    
    [Utils adjustUILabelHeight:self.lblTitle];
    [Utils adjustUILabelHeight:self.lblDetail];
    
    if ([perf isFreemium]) {
        self.vPro.hidden = YES;
    } else {
        self.vPro.hidden = NO;
    }
    
    CGFloat minCardSize = 200;
    
    CGFloat neededHeight = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 50 /*MIN SEP*/ + self.lblDetail.frame.size.height + 50 /* MIN SEP */ + 350-313 /* Más info abajo*/;
    
    /*
    if (perf.exclusive_acqustic) {
        self.vExclusive.hidden = NO;
        if (!self.vPro.hidden) {
            CGRect fr = self.vPro.frame;
            fr.origin.x = self.vExclusive.frame.origin.x + self.vExclusive.frame.size.width+10;
            self.vPro.frame = fr;
        }
    } else {
        self.vExclusive.hidden = YES;
        if (!self.vPro.hidden) {
            CGRect fr = self.vPro.frame;
            fr.origin.x = self.vExclusive.frame.origin.x;
            self.vPro.frame = fr;
        }
    }
    */
    
    self.vType.hidden = YES;
    if (perf.pub_mode) {
        if ([perf.pub_mode isEqualToString:@"PUBLIC"] || [perf.pub_mode isEqualToString:@"PRIVATE"]) {
            self.lblType.text = @"C"; self.vType.hidden = NO;
        } else if ([perf.pub_mode isEqualToString:@"PROMO"]) {
            self.lblType.text = @"P"; self.vType.hidden = NO;
        } else if ([perf.pub_mode isEqualToString:@"SOLIDARITY"]) {
            self.lblType.text = @"S"; self.vType.hidden = NO;
        } else {
            // Playlists
        }
    }
    
    if (neededHeight > minCardSize)
        minCardSize = neededHeight;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, minCardSize);
    self.contentView.frame = CGRectMake(0,0,self.frame.size.width, minCardSize);
    
    // Centramos el detalle
    self.lblDetail.frame = CGRectMake(self.lblDetail.frame.origin.x, (minCardSize-self.lblDetail.frame.size.height)/2, self.lblDetail.frame.size.width, self.lblDetail.frame.size.height);
    
    // Color
    self.contentView.backgroundColor = [Utils uicolorFromARGB:perf.flavour];
    
    
    return minCardSize;
}

-(void) adjustForHeight:(CGFloat)newHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
    self.contentView.frame = CGRectMake(0,0,self.frame.size.width, newHeight);
    
    // Centramos el detalle
    self.lblDetail.frame = CGRectMake(self.lblDetail.frame.origin.x, (newHeight-self.lblDetail.frame.size.height)/2, self.lblDetail.frame.size.width, self.lblDetail.frame.size.height);
}

@end
