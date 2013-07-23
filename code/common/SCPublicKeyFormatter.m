// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCPublicKeyFormatter.h"

@implementation SCPublicKeyFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing *)newString errorDescription:(NSString *__autoreleasing *)error {
    NSCharacterSet *invalidSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFabcdef0123456789:"] invertedSet];
    NSMutableString *theString = [[NSMutableString alloc] initWithCapacity:[partialString length]];
    for (int i = 0; i < [partialString length]; i++) {
        if (![invalidSet characterIsMember:[partialString characterAtIndex:i]]) {
            unichar theChar = [partialString characterAtIndex:i];
            [theString appendString:[NSString stringWithCharacters:&theChar length:1]];
        }
    }
    *newString = [(NSString*)theString uppercaseString];
    return NO;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    *anObject = string;
    return YES;
}

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NSString class]]) {
        // wtf
        return @"";
    } else return (NSString*)anObject;
}

@end
