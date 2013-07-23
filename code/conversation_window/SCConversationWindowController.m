// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCConversationWindowController.h"
#import "SCConversationViewController.h"
#import "SCChromeBGView.h"

@interface SCConversationWindowController ()

@end

@implementation SCConversationWindowController {
    SCConversationViewController *innerViewController;
}

- (id)initWithWindow:(NSWindow *)window chatContext:(SCChatContext *)theContext {
    self = [super initWithWindow:window];
    if (self) {
        self.context = theContext;
        window.title = @"Richard Stallman";
        window.minSize = (NSSize){400, 100};
        [window setContentBorderThickness:40 forEdge:NSMinYEdge];
        innerViewController = [[SCConversationViewController alloc] initWithNibName:@"Conversation" bundle:[NSBundle mainBundle]];
        [window setContentView:innerViewController.view];
        innerViewController.view.layer.cornerRadius = 8.0;
        innerViewController.bottomBar.roundsLeftCorner = YES;
        innerViewController.bottomBar.roundsRightCorner = YES;
        [innerViewController.splitView setPosition:innerViewController.splitView.frame.size.height - 40 ofDividerAtIndex:0];
    }
    return self;
}

@end
