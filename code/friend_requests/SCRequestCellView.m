// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCRequestCellView.h"

@implementation SCRequestCellView

- (void)drawRect:(NSRect)dirtyRect {
    if ([self isSelected]) {
        [[NSColor alternateSelectedControlColor] set];
        [self.publicKey setTextColor:[NSColor whiteColor]];
        [self.dateReceived setTextColor:[NSColor whiteColor]];
    } else {
        [[NSColor whiteColor] set];
        [self.publicKey setTextColor:[NSColor blackColor]];
        [self.dateReceived setTextColor:[NSColor controlShadowColor]];
    }
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
