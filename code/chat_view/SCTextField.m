#import "SCTextField.h"

@interface NSColor (SCTFColors)

+ (NSColor *)focusedColorForTextField;
+ (NSColor *)unfocusedColorForTextField;

@end

@implementation NSColor (SCTFColors)

+ (NSColor *)focusedColorForTextField {
    if (OS_VERSION_IS_BETTER_THAN_SNOW_LEOPARD) {
        return [NSColor colorWithCalibratedWhite:100.0 / 255.0 alpha:0.85];
    } else {
        return [NSColor colorWithCalibratedWhite:75.0 / 255.0 alpha:1.0];
    }
}

+ (NSColor *)unfocusedColorForTextField {
    if (OS_VERSION_IS_BETTER_THAN_SNOW_LEOPARD) {
        return [NSColor colorWithCalibratedWhite:100.0 / 255.0 alpha:0.4];
    } else {
        return [NSColor colorWithCalibratedWhite:100.0 / 255.0 alpha:0.5];
    }
}

@end

@implementation SCTextField {
    CGColorRef shadowColor;
}

- (void)awakeFromNib {
    NSColor *sColor = [NSColor whiteColor];
    NSInteger numberOfComponents = [sColor numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[sColor colorSpace] CGColorSpace];
    [sColor getComponents:(CGFloat *)&components];
    shadowColor = CGColorCreate(colorSpace, components);
    self.bezeled = YES;
    self.drawsBackground = NO;
    self.wantsLayer = YES;
    self.superview.layer.masksToBounds = NO;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = shadowColor;
    if (OS_VERSION_IS_BETTER_THAN_SNOW_LEOPARD) {
        self.layer.shadowOffset = (CGSize){0, 0.7};
        self.layer.shadowOpacity = 0.46;
    } else {
        self.layer.shadowOffset = (CGSize){0, -1};
        self.layer.shadowOpacity = 0.2;
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusChanged:) name:NSWindowDidBecomeKeyNotification object:newWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusChanged:) name:NSWindowDidResignKeyNotification object:newWindow];
}

- (void)focusChanged:(NSNotification *)notification {
    self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.window.isKeyWindow) {
        [[NSColor focusedColorForTextField] set];
    } else {
        [[NSColor unfocusedColorForTextField] set];
    }
    [[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:4.0 yRadius:4.0] fill];
    [[NSColor whiteColor] set];
    [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2) xRadius:3.42 yRadius:3.42] fill];
}

- (void)dealloc {
    if (shadowColor)
        CGColorRelease(shadowColor);
}

@end