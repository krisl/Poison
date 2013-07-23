// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>
@class SCChatContext;

@interface SCConversationWindowController : NSWindowController <NSWindowDelegate>

@property (strong) SCChatContext *context;

- (instancetype)initWithWindow:(NSWindow *)window chatContext:(SCChatContext *)theContext;

@end
