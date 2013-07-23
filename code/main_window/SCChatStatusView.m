// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <QuartzCore/QuartzCore.h>
#import "SCChatStatusView.h"

@implementation SCChatStatusView

- (void)awakeFromNib {
    self.backgroundColor = [NSColor colorWithCalibratedRed:0.9059 green:0.9176 blue:0.9451 alpha:1.0000];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSGradient *shadowGrad = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithCalibratedWhite:40 / 255.0 alpha:0.2]];
    NSBezierPath *shadowPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, self.bounds.size.width, 8)];
    [shadowGrad drawInBezierPath:shadowPath angle:90.0];
    [self.backgroundColor set];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 4, self.bounds.size.width, self.bounds.size.height - 4)] fill];
    NSGradient *highlightGrad = [[NSGradient alloc] initWithColors:@[self.backgroundColor, [NSColor colorWithCalibratedWhite:1.0 alpha:0.6], self.backgroundColor]];
    [highlightGrad drawInRect:NSMakeRect(0, 4, self.bounds.size.width, 1) angle:0];
}

@end
