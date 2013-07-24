// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCTOXNetworkConnection.h"
#include "Messenger.h"

#define POLL_REST_TIME 5000 // or 1/200th of a second

@implementation SCTOXNetworkConnection {
    NSThread *toxNetworkThread;
    NSString *nickname;
    NSString *bsAddr;
    NSInteger bsPort;
    NSString *bsKey;
    BOOL isCheckingForDHTConnection;
    NSDate *bootstrapStartTime;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _friendsManager = [[SCFriendListManager alloc] initWithConnection:self];
        isCheckingForDHTConnection = YES;
    }
    return self;
}

- (void)connectWithNickname:(NSString*)theNickname address:(NSString *)theAddress port:(NSInteger)thePort publicKey:(NSString *)theKey {
    nickname = theNickname;
    bsAddr = theAddress;
    bsPort = thePort;
    bsKey = theKey;
    bootstrapStartTime = [NSDate date];
    [self detachMessengerLoop];
}

- (void)disconnect {
    [self stopMessengerLoop];
    toxNetworkThread = nil;
    nickname = nil;
}


- (void) CALLS_INTO_CORE_FUNCTIONS messengerRunLoop {
    // todo: more gcd
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:@"DeepEndFriendMessageReceived" object:nil];
        IP_Port bootstrapInfo;
        NSArray *components = [bsAddr componentsSeparatedByString:@"."];
        NSAssert([components count] == 4, @"ip has more than 4 fragments???");
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        for (int i = 0; i < [components count]; i++) {
            bootstrapInfo.ip.c[i] = [[formatter numberFromString:components[i]] charValue];
        }
        bootstrapInfo.port = (uint16_t)htons(bsPort);
        bootstrapInfo.padding = 0;
        initMessenger();
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDidConnect" object:self userInfo:nil];
        });
        m_callback_namechange(SCDeepEndNameChanged);
        m_callback_userstatus(SCDeepEndStatusChanged);
        callback_friendrequest(SCDeepEndFriendRequestReceived);
        m_callback_friendmessage(SCDeepEndMessageReceived);
        NSLog(@"injected callbacks");
        uint8_t *publicKey = malloc(crypto_box_PUBLICKEYBYTES);
        SCDeepEndConvertPublicKeyString(bsKey, publicKey);
        DHT_bootstrap(bootstrapInfo, publicKey);
        free(publicKey);
        while (![toxNetworkThread isCancelled]) {
            if (isCheckingForDHTConnection && DHT_isconnected()) {
                self.bootstrapComplete = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BootstrapDidComplete" object:nil userInfo:nil];
                });
                isCheckingForDHTConnection = NO;
            } else if (isCheckingForDHTConnection && floor([bootstrapStartTime timeIntervalSinceNow] * -1.0) > 5.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BootstrapDidFail" object:nil userInfo:nil];
                });
                break;
        }
        doMessenger();
        usleep(POLL_REST_TIME);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDidDisconnect" object:self userInfo:nil];
        });
    }
}

- (void)detachMessengerLoop {
    toxNetworkThread = [[NSThread alloc] initWithTarget:self selector:@selector(messengerRunLoop) object:nil];
    [toxNetworkThread start];
}

- (void)stopMessengerLoop {
    [toxNetworkThread cancel];
}

- (NSString *) CALLS_INTO_CORE_FUNCTIONS publicKey {
    return SCDeepEndConvertPublicKeyData(self_public_key);
}

/*- (void)didReceiveFriendRequest:(NSNotification *)notification {
    m_addfriend_norequest((uint8_t*)[notification.userInfo[@"publicKey"] bytes]);
}*/

- (void) CALLS_INTO_CORE_FUNCTIONS didReceiveMessage:(NSNotification *)notification {
    m_sendmessage([notification.userInfo[@"friend"] intValue], (uint8_t*)"Install Gentoo", sizeof("Install Gentoo"));
}

BOOL SCPublicKeyIsValid(NSString *theKey) {
    if ([theKey length] != 64) {
        return NO;
    } else {
        NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefABCDEF1234567890"];
        int i = 0;
        while(i < [theKey length]) {
            if (![validSet characterIsMember:[theKey characterAtIndex:i]]) {
                return NO;
            }
            i++;
        }
    }
    return YES;
}

void CALLS_INTO_CORE_FUNCTIONS SCDeepEndFriendRequestReceived(uint8_t *publicKey, uint8_t *requestPayload, uint16_t payloadLength) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *thePayload = [[NSString alloc] initWithBytes:(const void*)requestPayload length:payloadLength encoding:NSUTF8StringEncoding]; // Assume UTF-8.
        NSData *theKey = [NSData dataWithBytes:(const void*)publicKey length:crypto_box_PUBLICKEYBYTES];
        NSLog(@"FR from %@: [%@]", theKey, thePayload);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeepEndFriendRequestReceived" object:nil userInfo:@{@"publicKey": theKey, @"payload": thePayload}]; // Post a notification to regain Objective-C object context.
    });
}

void CALLS_INTO_CORE_FUNCTIONS SCDeepEndMessageReceived(int friendID, uint8_t *messagePayload, uint16_t payloadLength) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *thePayload = [[NSString alloc] initWithBytes:(const void*)messagePayload length:payloadLength encoding:NSUTF8StringEncoding]; // Assume UTF-8.
        NSLog(@"From friend %i: %@", friendID, thePayload);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeepEndFriendMessageReceived" object:nil userInfo:@{@"payload": thePayload, @"friend": @(friendID)}]; // Post a notification to regain Objective-C object context.
    });
}

void CALLS_INTO_CORE_FUNCTIONS SCDeepEndNameChanged(int friendID, uint8_t *theName, uint16_t nameLength) {
    NSString *newName = [NSString stringWithCString:(char*)theName encoding:NSUTF8StringEncoding]; // Assume UTF-8.
    uint8_t *buffer = malloc(MAX_NAME_LENGTH);
    getname(friendID, buffer);
    NSString *oldName = [NSString stringWithCString:(char*)buffer encoding:NSUTF8StringEncoding];
    free(buffer);
    NSLog(@"From friend %i: NameChange %@ %@", friendID, oldName, newName);
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (newName && oldName)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeepEndNameChanged" object:@(friendID) userInfo:@{@"newName": newName, @"oldName": oldName, @"friend": @(friendID)}]; // Post a notification to regain Objective-C object context.
    });
}

void CALLS_INTO_CORE_FUNCTIONS SCDeepEndStatusChanged(int friendID, uint8_t *theStatus, uint16_t sLength) {
    NSString *newStatus = [NSString stringWithCString:(char*)theStatus encoding:NSUTF8StringEncoding]; // Assume UTF-8.
    uint16_t size = m_get_userstatus_size(friendID);
    uint8_t *buffer = malloc(size);
    m_copy_userstatus(friendID, buffer, size);
    NSString *oldStatus = [NSString stringWithCString:(char*)buffer encoding:NSUTF8StringEncoding];
    free(buffer);
    NSLog(@"From friend %i: StatusChange %@ %@", friendID, oldStatus, newStatus);
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (oldStatus && newStatus)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeepEndUserStatusChanged" object:@(friendID) userInfo:@{@"newStatus": newStatus, @"oldStatus": oldStatus, @"friend": @(friendID)}]; // Post a notification to regain Objective-C object context.
    });
}

void SCDeepEndConvertPublicKeyString(NSString *theString, uint8_t *theOutput) {
    const char *chars = [theString UTF8String];
    int i = 0, j = 0;
    NSUInteger len = [theString length];
    if ([theString length] != crypto_box_PUBLICKEYBYTES * 2) {
        [[[NSException alloc] initWithName:NSInvalidArgumentException reason:@"Malformed public key" userInfo:nil] raise];
    }
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte = 0;
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        theOutput[j++] = wholeByte;
    }
}

NSString *SCDeepEndConvertPublicKeyData(const uint8_t *theData) {
    uint8_t *buffer = malloc(crypto_box_PUBLICKEYBYTES);
    memcpy(buffer, theData, crypto_box_PUBLICKEYBYTES);
    NSMutableString *theString = [NSMutableString stringWithCapacity:crypto_box_PUBLICKEYBYTES * 2];
    for (NSInteger idx = 0; idx < crypto_box_PUBLICKEYBYTES; ++idx) {
        [theString appendFormat:@"%02x", buffer[idx]];
    }
    free(buffer);
    return [(NSString*)theString uppercaseString];
}

@end
