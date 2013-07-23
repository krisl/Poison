//
//  SCFriendCellView.m
//  Poison
//
//  Created by stal on 2013-07-16.
//  Copyright (c) 2013 The TOX Project. All rights reserved.
//

#import "SCFriendCellView.h"

@implementation SCFriendCellView {
    BOOL isCurrentlyCollapsed;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.selected) {
        NSGradient *shadowGrad = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithCalibratedWhite:0.071 alpha:0.3]];
        [[NSColor colorWithCalibratedWhite:0.118 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
        [shadowGrad drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, -4, self.bounds.size.width, 8)] angle:-90.0];
        [shadowGrad drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, self.bounds.size.height - 4, self.bounds.size.width, 8)] angle:90.0];
        
    } else {
        [[NSColor colorWithCalibratedWhite:0.15 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
        [[NSColor colorWithCalibratedWhite:0.221 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, self.bounds.size.height - 1, self.bounds.size.width, 1)] fill];
        [[NSColor colorWithCalibratedWhite:0.118 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, self.bounds.size.width, 1)] fill];
    }
    
}

@end
