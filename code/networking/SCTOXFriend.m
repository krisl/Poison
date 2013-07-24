// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCTOXFriend.h"
#import "Messenger.h"
#define MAX_MESSAGE_SIZE (MAX_DATA_SIZE - 17)

@implementation SCTOXFriend {
    uint8_t *_publicKey;
}

- (instancetype) CALLS_INTO_CORE_FUNCTIONS initWithFriendID:(int)theID {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameChanged:) name:@"DeepEndNameChanged" object:@(theID)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userStatusChanged:) name:@"DeepEndUserStatusChanged" object:@(theID)];
        _friendID = theID;
        _publicKey = malloc(crypto_box_PUBLICKEYBYTES);
        _userStatus = NSLocalizedString(@"Offline", @"");
        getclient_id(theID, _publicKey);
    }
    return self;
}

- (void)nameChanged:(NSNotification *)notification {
    [self willChangeValueForKey:@"nickname"];
    _nickname = notification.userInfo[@"newName"];
    [self didChangeValueForKey:@"nickname"];
}

- (void)userStatusChanged:(NSNotification *)notification {
    [self willChangeValueForKey:@"userStatus"];
    _userStatus = notification.userInfo[@"newStatus"];
    [self didChangeValueForKey:@"userStatus"];
}

- (BOOL) CALLS_INTO_CORE_FUNCTIONS sendMessage:(NSString *)message {
    NSArray *words = [message componentsSeparatedByString:@" "];
    NSUInteger len = 0;
    uint8_t *theBuffer = NULL;
    NSUInteger builtLength = 0;
    NSUInteger wordLength = 0;
    NSMutableArray *partialMessage = [[NSMutableArray alloc] initWithCapacity:[words count]];
    for (NSString *theWord in words) {
        wordLength = [theWord lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (builtLength + wordLength > MAX_MESSAGE_SIZE) {
            NSString *thePayload = [[partialMessage componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [partialMessage removeAllObjects];
            len = [thePayload lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
            theBuffer = malloc(len);
            memcpy(theBuffer, [thePayload UTF8String], len);
            int success = m_sendmessage(self.friendID, theBuffer, (uint16_t)len);
            free(theBuffer);
            builtLength = 0;
            if (!success) return NO;
        }
        [partialMessage addObject:theWord];
        builtLength += wordLength + 1;
    }
    if ([partialMessage count]) {
        NSString *thePayload = [[partialMessage componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [partialMessage removeAllObjects];
        len = [thePayload lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
        theBuffer = malloc(len);
        memcpy(theBuffer, [thePayload UTF8String], len);
        int success = m_sendmessage(self.friendID, theBuffer, (uint16_t)len);
        free(theBuffer);
        if (!success) return NO;
    }
    return YES;
}

- (NSString *)publicKey {
    uint8_t *buffer = malloc(crypto_box_PUBLICKEYBYTES);
    memcpy(buffer, _publicKey, crypto_box_PUBLICKEYBYTES);
    NSMutableString *theString = [NSMutableString stringWithCapacity:crypto_box_PUBLICKEYBYTES * 2];
    for (NSInteger idx = 0; idx < crypto_box_PUBLICKEYBYTES; ++idx) {
        [theString appendFormat:@"%02x", buffer[idx]];
    }
    free(buffer);
    return [(NSString*)theString uppercaseString];
}

- (void)dealloc {
    free(_publicKey);
}

@end
