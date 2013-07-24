// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#include "Messenger.h"
#import "SCFriendListManager.h"
#import "SCTOXNetworkConnection.h"
#import "SCFriendCellView.h"
#import "SCTOXFriend.h"

@interface SCTOXFriend (PrivateSetters)

- (void)setNickname:(NSString *)theNickname;
- (void)setUserStatus:(NSString *)theStatus;
- (void)setOnlineStatus:(SCTOXFriendStatus)theStatus;

@end

@implementation SCFriendListManager {
    NSMutableArray *_pendingRequests;
    NSMutableArray *_friends;
}

- (instancetype)initWithConnection:(SCTOXNetworkConnection *)connection {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendRequest:) name:@"DeepEndFriendRequestReceived" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDeleteFriend:) name:@"DeleteFriendAtCellIndex" object:nil];
        _pendingRequests = [[NSMutableArray alloc] initWithCapacity:16];
        _friends = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return self;
}

- (NSArray *)pendingRequests {
    return (NSArray*)_pendingRequests;
}

- (NSArray *)friends {
    return (NSArray*)_friends;
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

- (void) CALLS_INTO_CORE_FUNCTIONS acceptPendingFriendRequestWithPublicKey:(NSString *)theKey {
    uint8_t *keyData = malloc(crypto_box_PUBLICKEYBYTES);
    SCDeepEndConvertPublicKeyString(theKey, keyData);
    int friend = m_addfriend_norequest(keyData);
    free(keyData);
    if (friend > -1) {
        SCTOXFriend *newFriend = [[SCTOXFriend alloc] initWithFriendID:friend];
        [_friends addObject:newFriend];
        [self sortFriendList];
    }
    [_pendingRequests filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject[@"publicKey"] isEqualToString:[theKey uppercaseString]])
            return NO;
        else
            return YES;
    }]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendRequestCount" object:self userInfo:@{@"newCount": @(_pendingRequests.count)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendListView" object:self userInfo:nil];
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

- (void)sortFriendList {
    
}

#pragma mark - PXListView Delegate

- (NSUInteger)numberOfRowsInListView:(PXListView *)aListView {
    return [_friends count];
}

- (PXListViewCell *)listView:(PXListView *)aListView cellForRow:(NSUInteger)row {
    SCTOXFriend *theFriend = [_friends objectAtIndex:row];
    SCFriendCellView *cell = nil;
    if (!(cell = (SCFriendCellView*)[aListView dequeueCellWithReusableIdentifier:@"FriendCell"])) {
        cell = [SCFriendCellView cellLoadedFromNibNamed:@"FriendCell" bundle:[NSBundle mainBundle] reusableIdentifier:@"FriendCell"];
    }
    NSString *visibleNick = [theFriend nickname];
    if (!visibleNick) {
        visibleNick = [theFriend publicKey];
    }
    [cell assignFriend:_friends[row]];
    cell.nicknameLabel.stringValue = visibleNick;
    cell.userStatusLabel.stringValue = [theFriend userStatus];
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
