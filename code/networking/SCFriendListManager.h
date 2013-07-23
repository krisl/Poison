// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>
#import "PXListView.h"

@class SCFriendCellView, SCTOXNetworkConnection;

@interface SCFriendListManager : NSObject <PXListViewDelegate>

- (instancetype)initWithConnection:(SCTOXNetworkConnection *)connection;
- (NSArray *)pendingRequests;
- (void)addPendingFriendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)theMessage;
- (void)removePendingFriendRequestWithPublicKey:(NSString *)theKey;

@end
