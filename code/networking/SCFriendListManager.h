// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>
#import "PXListView.h"

@class SCFriendCellView, SCTOXNetworkConnection;

@interface SCFriendListManager : NSObject <PXListViewDelegate>

@property (readonly) NSArray *friends;
@property (readonly) NSArray *pendingRequests;

- (instancetype)initWithConnection:(SCTOXNetworkConnection *)connection;
- (void)addPendingFriendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)theMessage;
- (void)acceptPendingFriendRequestWithPublicKey:(NSString *)theKey;
- (void)removePendingFriendRequestWithPublicKey:(NSString *)theKey;

@end
