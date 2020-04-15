//
//  HeaderNav.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "HeaderNav.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"

@implementation HeaderNav

@synthesize contentView, ivLogo, vHome, ivHome, vNotis, ivNotis, badgeNotis, vChats, ivChats, badgeChats, vProfile, ivProfile;


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
        [bundle loadNibNamed:@"HeaderNav" owner:self options:nil];
        if (self.contentView) {
            [self addSubview:self.contentView];
            self.contentView.frame = self.bounds;
            
            [Utils setOnClick:self.ivLogo withBlock:^(UIView *sender) {
                [theApp.pages jumpToPage:@"HOME" withContext:nil];
            }];
            [Utils setOnClick:self.vHome withBlock:^(UIView *sender) {
                [theApp.pages jumpToPage:@"HOME" withContext:nil];
            }];
            [Utils setOnClick:self.vNotis withBlock:^(UIView *sender) {
                [theApp.pages jumpToPage:@"NOTIS" withContext:nil];
            }];
            [Utils setOnClick:self.vChats withBlock:^(UIView *sender) {
                [theApp.pages jumpToPage:@"CHATS" withContext:nil];
            }];
            [Utils setOnClick:self.vProfile withBlock:^(UIView *sender) {
                [theApp.pages jumpToPage:@"USER" withContext:nil];
                //[theApp.pages jumpToPage:@"COMPLETEFREEMIUM" withContext:nil];
            }];
            [self updateNotisBadge:0];
            [self updateChatsBadge:0];
        }
    }
}

-(void) prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self internalInit];
    [self.contentView prepareForInterfaceBuilder];
}

-(void) updateNotisBadge:(int)pending {
    if (pending > 0) {
        self.badgeNotis.text = [NSString stringWithFormat:@"%d", pending];
        [Utils adjustUILabelSize:self.badgeNotis];
        if (self.badgeNotis.frame.size.width < self.badgeNotis.frame.size.height) {
            CGRect fr = self.badgeNotis.frame;
            fr.size.width = fr.size.height;
            self.badgeNotis.frame = fr;
        }
        self.badgeNotis.hidden = NO;
    } else {
        self.badgeNotis.hidden = YES;
    }
}

-(void) updateChatsBadge:(int)pending {
    if (pending > 0) {
        self.badgeChats.text = [NSString stringWithFormat:@"%d", pending];
        [Utils adjustUILabelSize:self.badgeChats]  ;
        if (self.badgeChats.frame.size.width < self.badgeChats.frame.size.height) {
            CGRect fr = self.badgeChats.frame;
            fr.size.width = fr.size.height;
            self.badgeChats.frame = fr;
        }
        self.badgeChats.hidden = NO;
    } else {
        self.badgeChats.hidden = YES;
    }
}

-(void) setActiveSection:(int)section {
    switch (section) {
        case HEADER_SECTION_HOME:
            self.ivHome.image = [UIImage imageNamed:@"icon_header_home_on"];
            self.ivNotis.image = [UIImage imageNamed:@"icon_header_notis_off"];
            self.ivChats.image = [UIImage imageNamed:@"icon_header_chats_off"];
            self.ivProfile.image = [UIImage imageNamed:@"icon_header_profile_off"];
            break;
        case HEADER_SECTION_NOTIS:
            self.ivHome.image = [UIImage imageNamed:@"icon_header_home_off"];
            self.ivNotis.image = [UIImage imageNamed:@"icon_header_notis_on"];
            self.ivChats.image = [UIImage imageNamed:@"icon_header_chats_off"];
            self.ivProfile.image = [UIImage imageNamed:@"icon_header_profile_off"];
            break;
        case HEADER_SECTION_CHATS:
            self.ivHome.image = [UIImage imageNamed:@"icon_header_home_off"];
            self.ivNotis.image = [UIImage imageNamed:@"icon_header_notis_off"];
            self.ivChats.image = [UIImage imageNamed:@"icon_header_chats_on"];
            self.ivProfile.image = [UIImage imageNamed:@"icon_header_profile_off"];
            break;
        case HEADER_SECTION_USER:
            self.ivHome.image = [UIImage imageNamed:@"icon_header_home_off"];
            self.ivNotis.image = [UIImage imageNamed:@"icon_header_notis_off"];
            self.ivChats.image = [UIImage imageNamed:@"icon_header_chats_off"];
            self.ivProfile.image = [UIImage imageNamed:@"icon_header_profile_on"];
            break;
    }
}

-(void) setBadges:(NSDictionary *)badges {
    if (!badges || ((NSNull *)badges) == NSNull.null)
        return;
    if (badges[@"notis"]) {
        [self updateNotisBadge: [badges[@"notis"] intValue]];
    }
    if (badges[@"chats"]) {
        [self updateChatsBadge: [badges[@"chats"] intValue]];
    }
}

@end
