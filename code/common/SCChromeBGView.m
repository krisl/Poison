// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCChromeBGView.h"

@implementation SCChromeBGView {
    CGPoint initialLocation;
}

- (void)setRoundsLeftCorner:(BOOL)roundsLeftCorner {
    _roundsLeftCorner = roundsLeftCorner;
    [self setNeedsDisplay:YES];
}

- (void)setRoundsRightCorner:(BOOL)roundsRightCorner {
    _roundsRightCorner = roundsRightCorner;
    [self setNeedsDisplay:YES];
}

- (void)awakeFromNib {
    self.cornerRadius = 18;
}

- (void)viewDidMoveToWindow {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusChanged:) name:NSWindowDidBecomeKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusChanged:) name:NSWindowDidResignKeyNotification object:[self window]];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
}

- (void)focusChanged:(NSNotification*)notification {
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    initialLocation = [theEvent locationInWindow];
}

- (void)mouseUp:(NSEvent *)theEvent {
    initialLocation = CGPointZero;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (self.doesNotMoveWindow) {
        return;
    } else {
        NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
        NSRect windowFrame = [self.window frame];
        NSPoint newOrigin = windowFrame.origin;
        NSPoint currentLocation = [theEvent locationInWindow];
        newOrigin.x += (currentLocation.x - initialLocation.x);
        newOrigin.y += (currentLocation.y - initialLocation.y);
        if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
            newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
        }
        [self.window setFrameOrigin:newOrigin];
    }
}

- (NSGradient *)chromeForState {
    NSGradient *chrome = nil;
    if ([self isMainWindowFocused]) {
        chrome = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:146.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:217.0 / 255.0 alpha:1.0]];
    } else {
        chrome = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:208.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:237.0 / 255.0 alpha:1.0]];
    }
    return chrome;
}

- (NSColor *)shadowColour {
    return [NSColor colorWithCalibratedWhite:1.0 alpha:0.8];
}

- (BOOL)isMainWindowFocused {
    return [[self window] isKeyWindow];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSGradient *chrome = [self chromeForState];
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    [bgPath moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
    [bgPath lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    if (self.roundsRightCorner) {
        NSPoint bottomRightCorner = NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds));
        [bgPath lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + self.cornerRadius)];
        [bgPath curveToPoint:NSMakePoint(NSMaxX(self.bounds) - self.cornerRadius, NSMinY(self.bounds)) controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    } else {
        [bgPath lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    }
    if (self.roundsLeftCorner) {
        NSPoint bottomLeftCorner = NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds));
        [bgPath lineToPoint:NSMakePoint(NSMinX(self.bounds) + self.cornerRadius, NSMinY(self.bounds))];
        [bgPath curveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds) + self.cornerRadius) controlPoint1:bottomLeftCorner controlPoint2:bottomLeftCorner];
    } else {
        [bgPath lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    }
    [bgPath lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
    [chrome drawInBezierPath:bgPath angle:90];
    NSBezierPath *topShadow = [NSBezierPath bezierPathWithRect:NSMakeRect(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    NSColor *farPoint = nil;
    [chrome getColor:&farPoint location:NULL atIndex:1];
    NSGradient *highlightGrad = [[NSGradient alloc] initWithColors:@[farPoint, [self shadowColour], farPoint]];
    [highlightGrad drawInBezierPath:topShadow angle:0];
}

@end
