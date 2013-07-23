// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>

@interface SCTOXFriend : NSObject

@property (readonly) int friendID;
@property (readonly, strong) NSString *nickname;
@property (readonly, strong) NSString *userStatus;
- (instancetype)initWithFriendID:(int)theID;
- (BOOL)sendMessage:(NSString *)message;
- (NSString *)publicKey;

@end
