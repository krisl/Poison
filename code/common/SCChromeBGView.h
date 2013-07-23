// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@interface SCChromeBGView : NSView

@property CGFloat cornerRadius;
@property (nonatomic) BOOL roundsLeftCorner;
@property (nonatomic) BOOL roundsRightCorner;
@property BOOL doesNotMoveWindow;

- (NSGradient *)chromeForState;
- (NSColor *)shadowColour;
- (BOOL)isMainWindowFocused;

@end
