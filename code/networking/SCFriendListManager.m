// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCFriendListManager.h"
#import "SCTOXNetworkConnection.h"
#import "SCFriendCellView.h"

@implementation SCFriendListManager {
    NSMutableArray *_pendingRequests;
}

- (instancetype)initWithConnection:(SCTOXNetworkConnection *)connection {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendRequest:) name:@"DeepEndFriendRequestReceived" object:nil];
        _pendingRequests = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return self;
}

- (NSArray *)pendingRequests {
    return (NSArray*)_pendingRequests;
}

- (void)didReceiveFriendRequest:(NSNotification*)notification {
    [self addPendingFriendRequestWithPublicKey:SCDeepEndConvertPublicKeyData([notification.userInfo[@"publicKey"] bytes]) message:notification.userInfo[@"payload"]];
}

- (void)addPendingFriendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)theMessage {
    for (NSDictionary *request in _pendingRequests) {
        if ([request[@"publicKey"] isEqualToString:[publicKey uppercaseString]]) {
            return;
        }
    }
    NSMutableDictionary *theDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
    theDictionary[@"publicKey"] = [publicKey uppercaseString];
    theDictionary[@"message"] = theMessage;
    theDictionary[@"timeReceived"] = [NSDate date];
    [_pendingRequests addObject:(NSDictionary*)theDictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendRequestCount" object:self userInfo:@{@"newCount": @(_pendingRequests.count)}];
}

- (void)removePendingFriendRequestWithPublicKey:(NSString *)theKey {
    [_pendingRequests filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject[@"publicKey"] isEqualToString:[theKey uppercaseString]])
            return NO;
        else
            return YES;
    }]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendRequestCount" object:self userInfo:@{@"newCount": @(_pendingRequests.count)}];
}

#pragma mark - PXListView Delegate

- (NSUInteger)numberOfRowsInListView:(PXListView *)aListView {
    return 5;
}

- (PXListViewCell *)listView:(PXListView *)aListView cellForRow:(NSUInteger)row {
    SCFriendCellView *cell = nil;
    if (!(cell = (SCFriendCellView*)[aListView dequeueCellWithReusableIdentifier:@"FriendCell"])) {
        cell = [SCFriendCellView cellLoadedFromNibNamed:@"FriendCell" bundle:[NSBundle mainBundle] reusableIdentifier:@"FriendCell"];
    }
    return cell;
}

- (CGFloat)listView:(PXListView *)aListView heightOfRow:(NSUInteger)row {
    return 44;
}

- (void)listView:(PXListView *)aListView rowDoubleClicked:(NSUInteger)rowIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendCellDoubleClick" object:nil userInfo:@{@"representedFriend": @0}];
}

- (NSDragOperation)listView:(PXListView *)aListView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSUInteger)row proposedDropHighlight:(PXListViewDropHighlight)dropHighlight {
    return NSDragOperationEvery;
}

- (BOOL)listView:(PXListView *)aListView acceptDrop:(id<NSDraggingInfo>)info row:(NSUInteger)row dropHighlight:(PXListViewDropHighlight)dropHighlight {
    return YES;
}
@end
