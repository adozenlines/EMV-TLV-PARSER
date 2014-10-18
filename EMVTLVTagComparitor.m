//
//  TVLTagComparitor.m
//
//  Created by Damon Yuan on 11/6/14.
//

#import "EMVTLVTagComparitor.h"
#import "EMVTLV.h"
#import "EMVTag.h"
#import "EMVTLVDescription.h"

@interface EMVTLVTagComparitor()
@property (nonatomic, strong) NSMutableDictionary* tagPaths;
@end

@implementation EMVTLVTagComparitor

- (instancetype)initWithArgs:(id)_args
{
    self = [super init];
    if (self) {
        self.tagPaths = [[NSMutableDictionary alloc] init];
        if ([_args class] == [EMVTLV class]||[[_args class]isSubclassOfClass:[EMVTLV class]]) {
            [self _buildFromTLV:_args];
        }
        if ([_args class] == [NSArray class]||[[_args class]isSubclassOfClass:[NSArray class]]) {
            int i = 0;
            for (id tagPath in _args) {
                i++;
                NSString* temp = (NSString*)tagPath;
                [self.tagPaths setObject:[NSNumber numberWithInt:i] forKey:temp];
            }
        }
    }
    return self;
}

// This is to seperate the tagPath for each tag
+ (NSMutableArray*)tagPathDifferentiator:(NSString*)tagPath
{
    NSArray *subStrings = [tagPath componentsSeparatedByString:@"0x"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[subStrings count]-1];
    for (int i = 1; i < [subStrings count]; i++) {
        @autoreleasepool {
            NSMutableString* tempSubString = [NSMutableString stringWithString:@"0x"];
            [tempSubString appendString:[subStrings objectAtIndex:i]];
            [returnArray addObject:tempSubString];
        }
    }
    return returnArray;
}

+ (NSMutableString*)tagPathCombinar:(NSMutableArray*)returnArray
{
    NSMutableString* tagPath = [[NSMutableString alloc] init];
    for (int i = 0; i<[returnArray count]; i ++) {
        [tagPath appendString:[returnArray objectAtIndex:i]];
    }
    return tagPath;
}

- (void)_buildFromTLV:(EMVTLV*)tlv
{
    int i = 0;
    for (id object in tlv.objects) {
        NSMutableString* tagPath = [[NSMutableString alloc] init];
        TagValueCouple* temp = (TagValueCouple*)object;
        EMVTag* temp_tag = [temp objectAtIndex:0];
        
        if ([temp_tag constructed]&&([[temp objectAtIndex:1] class]==[EMVTLV class]||[[[temp objectAtIndex:1]class]isSubclassOfClass:[EMVTLV class]])) {
            [tagPath appendString:[temp_tag serialiseTag]];
            [self _buildFromTLV:[temp objectAtIndex:1]];
        }else if(![temp_tag constructed] && ([[temp objectAtIndex:1]class] == [NSData class]||[[[temp objectAtIndex:1]class]isSubclassOfClass:[NSData class]])){
            i++;
            [tagPath appendString:[temp_tag serialiseTag]];
            [self.tagPaths setObject:[NSNumber numberWithInt:i] forKey:tagPath];
        }else{
            NSLog(@"Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, @"(un)constructed tag/value mismatch");
        }
    }
}

- (BOOL)match:(EMVTLV*)tlv
{
    BOOL result = true;
    result = (result && ([self empty] == [tlv empty]));
    for (NSString* tagPath in self.tagPaths) {
        result = result && ([[tlv _search:tagPath]count]>0);
    }
    return result;
}

- (BOOL)matchExact:(EMVTLV*)tlv
{
    return [self isEqual:[[EMVTLVTagComparitor alloc] initWithArgs:tlv]];
}

- (BOOL)empty
{
    return [self.tagPaths count]==0;
}

// Get the tag object based on the description
- (EMVTag*)tagLookup:(NSString*)description
{
    NSArray* a = [[self _getDescriptions] allKeysForObject:description];
    if ([a count]==0) {
        NSLog(@"Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, @"No Tag for this description");
        return nil;
    }
    if ([a count] == 1) {
        EMVTag* tag = [[EMVTag alloc] initWithTag:[a objectAtIndex:0]];
        return tag;
    }
    NSLog(@"Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, @"Duplicated description");
    return nil;
}

- (NSDictionary*)_getDescriptions
{
    return [EMVTLVDescription getTLVDescription];
}


@end
