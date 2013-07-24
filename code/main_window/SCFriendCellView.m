//
//  SCFriendCellView.m
//  Poison
//
//  Created by stal on 2013-07-16.
//  Copyright (c) 2013 The TOX Project. All rights reserved.
//

#import "SCFriendCellView.h"
#import "SCTOXFriend.h"

@implementation SCFriendCellView {
    BOOL isCurrentlyCollapsed;
    SCTOXFriend *assignedFriend;
}

- (IBAction)sendForkNewWindowNotification:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendCellDoubleClick" object:nil userInfo:@{@"representedFriend": @0}];
}

- (IBAction)sendRemoveFriendNotification:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteFriendAtCellIndex" object:nil userInfo:@{@"forCell": @([self row])}];
}

- (void)assignFriend:(SCTOXFriend *)theFriend {
    assignedFriend = theFriend;
    [theFriend addObserver:self forKeyPath:@"nickname" options:NSKeyValueObservingOptionNew context:NULL];
    [theFriend addObserver:self forKeyPath:@"userStatus" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)prepareForReuse {
    [assignedFriend removeObserver:self forKeyPath:@"nickname"];
    [assignedFriend removeObserver:self forKeyPath:@"userStatus"];
    assignedFriend = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != assignedFriend) {
        return;
    }
    if ([keyPath isEqualToString:@"nickname"]) {
        self.nicknameLabel.stringValue = change[NSKeyValueChangeNewKey];
    } else if ([keyPath isEqualToString:@"userStatus"]) {
        self.userStatusLabel.stringValue = change[NSKeyValueChangeNewKey];
    }
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
