// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>
#import "SCFriendListManager.h"

@interface SCTOXNetworkConnection : NSObject

@property (strong, readonly) SCFriendListManager *friendsManager;
@property BOOL bootstrapComplete;

- (void)connectWithNickname:(NSString*)theNickname address:(NSString *)theAddress port:(NSInteger)thePort publicKey:(NSString *)theKey;
- (void)disconnect;
- (void)detachMessengerLoop;
- (void)stopMessengerLoop;
- (NSString*)publicKey;

BOOL SCPublicKeyIsValid(NSString *theKey);
void SCDeepEndConvertPublicKeyString(NSString *theString, uint8_t *theOutput);
NSString *SCDeepEndConvertPublicKeyData(const uint8_t *theData);

@end
