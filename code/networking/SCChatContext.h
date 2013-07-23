// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface SCChatContext : NSObject
@property (strong) NSArray *participants;

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector;
- (instancetype)initWithParticipants:(NSArray *)theParticipants;
// Exported to JavaScript
- (NSString *)URLToUserProfileImage:(NSString *)clientID;
- (NSArray *)participantIDs;
- (NSString *)nameForClientID:(NSString *)clientID;
- (NSArray *)chatHistory;
- (NSNumber *)systemControlColor;

@end
