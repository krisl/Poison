// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCDarkChromeBGView.h"

@implementation SCDarkChromeBGView

- (NSGradient *)chromeForState {
    return [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.09 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1.0]];
}

- (NSColor *)shadowColour {
    return [NSColor colorWithCalibratedWhite:1.0 alpha:0.3];
}

@end
