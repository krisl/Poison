// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCChatContext.h"
static NSSet *exportedSelectors = nil;

@implementation SCChatContext
+ (void)initialize {
    NSMutableSet *theSet = [[NSMutableSet alloc] initWithObjects:@"URLToUserProfileImage:", @"participantIDs", @"nameForClientID:", @"chatHistory", @"systemControlColor", nil];
    exportedSelectors = (NSSet*)theSet;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector {
    if ([exportedSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    } else {
        return NO;
    }
}

- (instancetype)initWithParticipants:(NSArray *)theParticipants {
    self = [super init];
    if (self) {
        self.participants = theParticipants;
    }
    return self;
}

// Exported to JavaScript
- (NSString *)URLToUserProfileImage:(NSString *)clientID {
    return @"";
}
- (NSArray *)participantIDs {
    return @[];
}
- (NSString *)nameForClientID:(NSString *)clientID {
    return @"";
}
- (NSArray *)chatHistory {
    return @[];
}
- (NSNumber *)systemControlColor {
    NSControlTint currentTint = [NSColor currentControlTint];
    switch (currentTint) {
        case NSBlueControlTint:
            return @(1);
        case NSGraphiteControlTint:
            return @(2);
        default:
            return @(0);
    }
}

@end
