//
//  Distribution.h
//  Acqustic
//
//  Created by Javier Garc�s Gonz�lez on 06/03/13.
//  Copyright (c) 2013 Sinergia sistemas inform�ticos S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Distribution : NSObject {
    NSInteger group_member;
    NSInteger group_member_percentage;
    NSString * group_member_documents;
}

@property NSInteger group_member;
@property NSInteger group_member_percentage;
@property NSString * group_member_documents;

-(id) init;
-(id) initWithJSONString:(NSString *)json;
-(id) initWithDictionary:(NSDictionary *)data;

@end
