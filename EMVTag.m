//
//  EMVTag.h
//
//  Created by Damon Yuan on 8/6/14.
//

#import "EMVTag.h"
#import "NSData+HexNSString.h"
#import "EMVTLVDescription.h"

@interface EMVTag(){

}
@end
@implementation EMVTag

// Argument tagData can be nsdata or nsstring.
- (instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (instancetype)initWithTag:(NSData *)tagData
{
    self = [super init];
    if (self) {
         self.tagData = [NSData dataWithData:tagData];
    }
    return self;
}

-(BOOL)constructed
{
    Byte buf;
    NSRange range = NSMakeRange(0, 1);
    [self.tagData getBytes:&buf range:range];
    return ((buf & 0x20) == 0x20);
}

// String from nsdata
- (NSString* )serialiseTag
{
    NSData *data = self.tagData;
    NSUInteger capacity = data.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
    }
    NSMutableString *temp = [NSMutableString stringWithString:@"0x"];
    [temp appendString:sbuf];
    
    return [NSString stringWithString:temp];
}

// Get the description based on the tag
- (NSString*)description
{
    NSString* tagString = [self serialiseTag];
    return [[self _getDescriptions] valueForKey:tagString];
}

// Get the tag object based on the description
+ (EMVTag*)tagLookup:(NSString*)description
{
    NSDictionary* descriptions = [EMVTLVDescription getTLVDescription];
    NSArray* a = [descriptions allKeysForObject:description];
    
    if ([a count]==0) {
        NSLog(@"Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, @"No Tag for this description");
        return nil;
    }
    
    if ([a count] == 1) {
        EMVTag* tag = [[EMVTag alloc] initWithTag:[NSData hexStringToData:[a objectAtIndex:0]]];
        return tag;
    }
    
    return nil;
}

- (NSString*)_descriptionForKey:(NSString*)key
{
    NSString* _key = [key lowercaseString];
    return [[self _getDescriptions] valueForKey:_key];
}

- (NSDictionary*)_getDescriptions
{
    NSDictionary* descriptions = [EMVTLVDescription getTLVDescription];
    return descriptions;
}
@end
