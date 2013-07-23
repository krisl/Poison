// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCChatBaseBackgroundView.h"

@implementation SCChatBaseBackgroundView

- (void)awakeFromNib {
    self.backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.7922 green:0.8157 blue:0.8627 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.9059 green:0.9176 blue:0.9451 alpha:1.0]];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundGradient drawInBezierPath:[NSBezierPath bezierPathWithRect:self.bounds] angle:90];
}

@end
