//
//  PerformanceCardBack.m
//  Nestor
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PerformanceCardBack.h"
#import "Utils.h"
#import "Acqustic.h"
#import "AppDelegate.h"
#import "NSDate+Utilities.h"
#import "NSAttributedString+DDHTML.h"
#import "WSDataManager.h"

@implementation PerformanceCardBack

@synthesize contentView, lblTitle, lblDescription, lblDetail;
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
        [bundle loadNibNamed:@"PerformanceCardBack" owner:self options:nil];
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

-(NSString *) title {
    if (!self.lblTitle)
        return nil;
    return self.lblTitle.text;
}

-(void) setTitle:(NSString *)title {
    if (!self.lblTitle)
        return;
    self.lblTitle.text = title;
}

-(CGFloat) setPerformance:(Performance *)perf {
    self.perf = perf;
    self.lblTitle.text = perf.name;
    self.lblDescription.text = perf.description;
    
    // Montamos el bloque de información
    NSString * date = [Utils formatDate:perf.performance_date withFormat:@"EEEE d MMM"];
    NSString * hour = [Utils formatTime:perf.performance_date];
    if (perf.performance_enddate != 0 && perf.performance_enddate != perf.performance_date) {
        hour = [hour stringByAppendingFormat:@" - %@", [Utils formatTime:perf.performance_enddate]];
    }
    NSString * location = perf.provisional_location;
    NSString * type = [perf getTypologyAsText];
    NSString * memberCount = [perf getMemberCountFormatted];
    NSString * cache = [perf getCacheFormatted];
    NSDictionary * imgMap = @{
        @"icon_card_date": [UIImage imageNamed:@"icon_card_date.png"],
        @"icon_card_hour": [UIImage imageNamed:@"icon_card_hour.png"],
        @"icon_card_location": [UIImage imageNamed:@"icon_card_location.png"],
        @"icon_card_type": [UIImage imageNamed:@"icon_card_type.png"],
        @"icon_card_membercount": [UIImage imageNamed:@"icon_card_membercount.png"],
        @"icon_card_cache": [UIImage imageNamed:@"icon_card_cache.png"],
    };
    NSString * infoBlock = @"";
    if (date && ![date isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_date' width='30' height='30'> %@</p>", date];
    }
    if (hour && ![hour isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_hour' width='30' height='30'> %@</p>", hour];
    }
    if (location && ![location isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_location' width='30' height='30'> %@</p>", location];
    }
    if (type && ![type isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_type' width='30' height='30'> %@</p>", type];
    }
    if (memberCount && ![memberCount isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_membercount' width='30' height='30'> %@</p>", memberCount];
    }
    if (cache && ![cache isEqualToString:@""]) {
        infoBlock = [infoBlock stringByAppendingFormat:@"<p _paragraphSpacing='5'><img src='icon_card_cache' width='30' height='30'> %@</p>", cache];
    }
    infoBlock = [infoBlock stringByAppendingString:@"<p></p>"]; // Centinela, si no se come el último
    lblDetail.attributedText = [NSAttributedString attributedStringFromHTML:infoBlock normalFont:lblDetail.font boldFont:lblDetail.font italicFont:lblDetail.font imageMap:imgMap];
    
    NSLog(@"CACHE: %@ - %@", perf.name, [perf getCacheFormatted]);
    NSLog(@"INFOBLOCK: %@", infoBlock);
    
    [Utils adjustUILabelHeight:self.lblTitle];
    [Utils adjustUILabelHeight:self.lblDescription];
    [Utils adjustUILabelHeight:self.lblDetail];
    
    // Tamaño mínimo de la card (tiene que ser igual en el front y el back!!!)
    CGFloat minCardSize = 200;
    
    CGFloat neededHeight = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 30 /*MIN SEP*/ + self.lblDescription.frame.size.height + 30 /* MIN SEP */ + self.lblDetail.frame.size.height + 50 /* MIN SEP */ +350-305 /* Más info abajo*/;
    
    if (neededHeight > minCardSize)
        minCardSize = neededHeight;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, minCardSize);
    self.contentView.frame = CGRectMake(0,0,self.frame.size.width, minCardSize);
    
    // Colocamos los textos
    self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x, self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 30, self.lblDescription.frame.size.width, self.lblDescription.frame.size.height);

    self.lblDetail.frame = CGRectMake(self.lblDetail.frame.origin.x,self.lblDescription.frame.origin.y + self.lblDescription.frame.size.height + 30, self.lblDetail.frame.size.width, self.lblDetail.frame.size.height);
    
    if (perf.already_registered) {
        [self.btnSubscribe setTitle:@"Ya estoy inscrito" forState:UIControlStateNormal];
    } else {
        [self.btnSubscribe setTitle:@"Incribirme" forState:UIControlStateNormal];
    }
    
    [self.btnSubscribe addTarget:self action:@selector(selectPerformance:) forControlEvents:UIControlEventTouchUpInside];
    
    return minCardSize;
}

-(void) adjustForHeight:(CGFloat)newHeight {
    self.frame = CGRectMake(0, 0, self.frame.size.width, newHeight);
    self.contentView.frame = CGRectMake(0,0,self.frame.size.width, newHeight);
    
    // Centramos el detalle
    self.lblDetail.frame = CGRectMake(self.lblDetail.frame.origin.x, (newHeight-self.lblDetail.frame.size.height)/2, self.lblDetail.frame.size.width, self.lblDetail.frame.size.height);
}

-(void)selectPerformance:(UIButton *)button {
    PageContext * ctx = [[PageContext alloc] init];
    [ctx addParam:@"performanceId" withIntValue:self.perf._id];
    // Actualizamos el perfil primero, por si ha cambiado el estado de la suscripción
    [WSDataManager getProfile:^(int code, NSDictionary *result, NSDictionary *badges) {
        if (code == WS_SUCCESS) {
            // Si está suscrito, seguimos. Si no, a suscripciones
            if ([theApp.appSession isSubscribed] || [self.perf isFreemium]) {
                [theApp.pages jumpToPage:@"PERFORMANCEREGISTER" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            } else {
                [theApp.pages jumpToPage:@"USERSUBSCRIPTION" withContext:ctx withTransition:AppDelegate.transPushRL andBackTransition:AppDelegate.transPushLR ignoreHistory:NO];
            }
        } else {
            [theApp stdError:code];
        }
    }];
    
}

@end
