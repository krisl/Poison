// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@class PXListView, SCDarkToolbarButton;
@interface SCMainChatWindowController : NSWindowController <NSWindowDelegate, NSSplitViewDelegate>

@property (strong) IBOutlet PXListView *friendsList;
@property (strong) IBOutlet NSTextField *nicknameField;
@property (strong) IBOutlet NSTextField *statusField;
@property (strong) IBOutlet NSImageView *userImageView;
@property (strong) IBOutlet NSSplitView *splitView;
@property (strong) IBOutlet NSView *sidebar;
@property (strong) IBOutlet NSButton *friendRequestsButton;
@property (strong) IBOutlet NSTextField *friendRequestsCount;
- (void)showAddFriendModal;

@end
