// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCWBackgroundView.h"

@implementation SCWBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] set];
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    NSGradient *shadow = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithCalibratedWhite:20.0 / 255.0 alpha:0.3]];
    NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, self.bounds.size.height - 4, self.bounds.size.width, 4)];
    [shadow drawInBezierPath:shadowPath angle:90.0];
}

@end
