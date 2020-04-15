//
//  PagePerfResume.m
//  Bookeat
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PagePerfResume.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "WSDataManager.h"
#import "NSAttributedString+DDHTML.h"

@interface PagePerfResume ()

@end

@implementation PagePerfResume

@synthesize svContent, lblTitle, lblDescription, lblDetail, lblGroup;

-(BOOL)onPreloadPage:(PageContext *)context {
    [theApp showBlockView];
    
    performanceId = [context intParamByName:@"performanceId"];
    
    PagePerfResume * refThis = self;
    [WSDataManager getPerformance:performanceId withBlock:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            refThis->performance = [[Performance alloc] initWithDictionary:result];
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    
    return YES;
}

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];
    [self setTopColor:[Utils uicolorFromARGB:0xFF333333]];
    [self setBottomColor:[Utils uicolorFromARGB:0xFF333333]];


    [self loadNIB:@"PagePerfResume"];
    //[super setTopColor:RACC_YELLOW];

    _ctx = context;
    
    self.lblTitle.text = performance.name;
    self.lblDescription.text = performance.description;
    
    // Montamos el bloque de información
    NSString * date = [Utils formatDate:performance.performance_date withFormat:@"EEEE d MMM"];
    NSString * hour = [Utils formatTime:performance.performance_date];
    if (performance.performance_enddate != 0 && performance.performance_enddate != performance.performance_date) {
        hour = [hour stringByAppendingFormat:@" - %@", [Utils formatTime:performance.performance_enddate]];
    }
    NSString * location = performance.provisional_location;
    NSString * venue = [performance getVenue];
    NSString * type = [performance getTypologyAsText];
    NSString * equipment = performance.group_equipment;
    NSString * memberCount = [performance getMemberCountFormatted];
    NSString * cache = [performance getCacheFormatted];
    NSString * info = performance.group_info;
    NSDictionary * imgMap = @{
        @"icon_card_date": [UIImage imageNamed:@"icon_card_date_white.png"],
        @"icon_card_hour": [UIImage imageNamed:@"icon_card_hour_white.png"],
        @"icon_card_location": [UIImage imageNamed:@"icon_card_location_white.png"],
        @"icon_card_venue": [UIImage imageNamed:@"icon_card_venue_white.png"],
        @"icon_card_type": [UIImage imageNamed:@"icon_card_type_white.png"],
        @"icon_card_equipment": [UIImage imageNamed:@"icon_card_equipment_white.png"],
        @"icon_card_membercount": [UIImage imageNamed:@"icon_card_membercount_white.png"],
        @"icon_card_cache": [UIImage imageNamed:@"icon_card_cache_white.png"],
        @"icon_card_info": [UIImage imageNamed:@"icon_card_info_white.png"],
    };
    NSString * infoBlock = @"";
    if (date && ![date isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_date' width='30' height='30'> %@</p>", date];
    }
    if (hour && ![hour isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_hour' width='30' height='30'> %@</p>", hour];
    }
    if (venue && ![venue isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_venue' width='30' height='30'> %@</p>", venue];
    }
    if (location && ![location isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_location' width='30' height='30'> %@</p>", location];
    }
    if (type && ![type isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_type' width='30' height='30'> %@</p>", type];
    }
    if (equipment && ![equipment isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_equipment' width='30' height='30'> %@</p>", equipment];
    }
    if (memberCount && ![memberCount isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_membercount' width='30' height='30'> %@</p>", memberCount];
    }
    if (cache && ![cache isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_cache' width='30' height='30'> %@</p>", cache];
    }
    if (info && ![info isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_info' width='30' height='30'> %@</p>", info];
    }
    infoBlock = [infoBlock stringByAppendingString:@"<p></p>"]; // Centinela, si no se come el último
    lblDetail.attributedText = [NSAttributedString attributedStringFromHTML:infoBlock normalFont:lblDetail.font boldFont:lblDetail.font italicFont:lblDetail.font imageMap:imgMap];

    // Miramos el grupo
    NSInteger groupId = [context intParamByName:@"groupId"];
    if (groupId != 0) {
        for (int i=0;i<theApp.appSession.performerProfile.groups.count;i++) {
            Group * g = theApp.appSession.performerProfile.groups[i];
            if (g._id == groupId) {
                theApp.appSession.currentGroup = g;
            }
        }
    }
    self.lblGroup.text = theApp.appSession.currentGroup.name;

    // Miramos de poner el link a roadmap si lo hay
    if ([performance isWinner] && ![performance.roadmap_document isEqualToString:@""]) {
        self.btnRuta.hidden = NO;
        [Utils setOnClick:self.btnRuta withBlock:^(UIView *sender) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:self->performance.roadmap_document]];
        }];
    } else {
        self.btnRuta.hidden = YES;
    }

    // Ajustamos el tamaño de cada bloque
    [Utils adjustUILabelHeight:self.lblTitle];
    [Utils adjustUILabelHeight:self.lblDescription];
    [Utils adjustUILabelHeight:self.lblGroup];
    [Utils adjustUILabelHeight:self.lblDetail];
    [Utils setupVerticalRaw:@[self.lblTitle, self.lblDescription, self.lblGroup, self.lblDetail] sep:30];
    // Recolocamos los elementos
    
    [Utils setOnClick:self.btnBack withBlock:^(UIView *sender) {
        [theApp.pages goBack];
    }];
    

}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}


@end
