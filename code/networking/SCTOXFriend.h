// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>

typedef enum SCTOXFriendStatus {
    SCTOXFriendStatusOnline = 4,
    SCTOXFriendStatusConfirmed = 3,
    SCTOXFriendStatusRequestSent = 2,
    SCTOXFriendStatusAdded = 1,
    SCTOXFriendStatusNonexistent = 0;
} SCTOXFriendStatus;

@interface SCTOXFriend : NSObject

@property (readonly) int friendID;
@property (readonly, strong) NSString *nickname;
@property (readonly, strong) NSString *userStatus;
@property (readonly) NSString *publicKey;
- (instancetype)initWithFriendID:(int)theID;
- (BOOL)sendMessage:(NSString *)message;

@end
