// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>
@class WebView, SCChatStatusView, SCChromeBGView, SCChatBaseBackgroundView;
@interface SCConversationViewController : NSViewController
@property (strong) IBOutlet NSTextField *messageEntry;
@property (strong) IBOutlet SCChatStatusView *chatStatus;
@property (strong) IBOutlet NSButton *sendButton;
@property (strong) IBOutlet WebView *transcriptView;
@property (strong) IBOutlet NSSplitView *splitView;
@property (strong) IBOutlet SCChromeBGView *bottomBar;
@property (strong) IBOutlet SCChatBaseBackgroundView *chatBase;
@property (strong) IBOutlet NSTextField *chatPartner;
@property (strong) IBOutlet NSTextField *lastMessage;
- (void)setBottomBarHeight:(CGFloat)newHeight;
@end
