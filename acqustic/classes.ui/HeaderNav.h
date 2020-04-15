//
//  HeaderNav.h
//  vlexmobile
//
//  Created by Javier Garcés González on 30/5/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEADER_CMD_HOME         1000
#define HEADER_CMD_NOTIS        1001
#define HEADER_CMD_CHATS        1002
#define HEADER_CMD_USER         1003

#define HEADER_SECTION_HOME     1000
#define HEADER_SECTION_NOTIS    1001
#define HEADER_SECTION_CHATS    1003
#define HEADER_SECTION_USER     1002


IB_DESIGNABLE
@interface HeaderNav : UIView {
    
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIImageView *ivLogo;
@property (strong, nonatomic) IBOutlet UIView *vHome;
@property (strong, nonatomic) IBOutlet UIImageView *ivHome;
@property (strong, nonatomic) IBOutlet UIView *vNotis;
@property (strong, nonatomic) IBOutlet UIImageView *ivNotis;
@property (strong, nonatomic) IBOutlet UILabel *badgeNotis;
@property (strong, nonatomic) IBOutlet UIView *vChats;
@property (strong, nonatomic) IBOutlet UIImageView *ivChats;
@property (strong, nonatomic) IBOutlet UILabel *badgeChats;
@property (strong, nonatomic) IBOutlet UIView *vProfile;
@property (strong, nonatomic) IBOutlet UIImageView *ivProfile;

-(void) prepareForInterfaceBuilder;
-(void) updateNotisBadge:(int)pending;
-(void) updateChatsBadge:(int)pending;
-(void) setActiveSection:(int)section;
-(void) setBadges:(NSDictionary *)badges;

@end
