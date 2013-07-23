// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>
#import "PXListView.h"

@interface SCFriendRequestListingController : NSWindowController <PXListViewDelegate>

@property (strong) IBOutlet PXListView *listView;
@property (strong) IBOutlet NSTextField *openRequestPublicKey;
@property (strong) IBOutlet NSTextField *openRequestTimestamp;
@property (strong) IBOutlet NSButton *trustCheck;
@property (strong) IBOutlet NSTextView *messageView;
@property (strong) IBOutlet NSButton *acceptButton;
@property (strong) IBOutlet NSButton *ignoreButton;
@property (strong) IBOutlet NSView *requestFormView;

@end
