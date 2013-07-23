// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCChatBaseBackgroundView.h"
#import "SCConversationViewController.h"
#import "SCChromeBGView.h"
#import <WebKit/WebKit.h>

@interface SCConversationViewController ()
@end

@implementation SCConversationViewController

- (void)setBottomBarHeight:(CGFloat)newHeight {
    [self.bottomBar setFrameSize:(NSSize){self.bottomBar.frame.size.width, newHeight}];
}

- (void)frameDidChange:(NSNotification *)notification {
    [self.splitView setPosition:self.splitView.frame.size.height - 40 ofDividerAtIndex:0];
    [self.transcriptView setFrameOrigin:(NSPoint){0, 0}];
    [self.transcriptView setFrameSize:(NSSize){self.chatBase.frame.size.width, self.chatBase.frame.size.height - 27}];
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self.view];
    self.transcriptView.drawsBackground = NO;
    [self frameDidChange:nil];
    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TranscriptViewBaseAlternate" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    [[self.transcriptView mainFrame] loadHTMLString:html baseURL:[NSURL URLWithString:@"https://boards.4chan.org/g/"]];
}

@end
