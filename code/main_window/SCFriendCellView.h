// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"

@class SCTOXFriend;
@interface SCFriendCellView : PXListViewCell

@property (strong) IBOutlet NSImageView *userImageView;
@property (strong) IBOutlet NSTextField *userStatusLabel;
@property (strong) IBOutlet NSTextField *nicknameLabel;
@property (strong) IBOutlet NSImageView *userOnlineLight;
- (void)assignFriend:(SCTOXFriend *)theFriend;

@end
