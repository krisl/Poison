// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@class SCTOXNetworkConnection;

@interface SCAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (strong) NSArray *friendsList;
@property (strong) NSString *nickname;
@property (strong) SCTOXNetworkConnection *connection;
@property BOOL shouldForgetEverything;

- (void)connectTOXWithBootstrapAddress:(NSString*)theAddress port:(NSInteger)thePort publicKey:(NSString *)theKey;

@end
