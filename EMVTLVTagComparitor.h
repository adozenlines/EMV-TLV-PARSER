//
//  TVLTagComparitor.m
//
//  Created by Damon Yuan on 11/6/14.
//

typedef NSArray                      TagValueCouple;
typedef NSArray                      LengthValueCouple;
#import <Foundation/Foundation.h>

@class EMVTLV;
@class EMVTag;
@interface EMVTLVTagComparitor : NSObject

- (instancetype)initWithArgs:(id)_args;
- (EMVTag*)tagLookup:(NSString*)description;
+ (NSMutableArray*)tagPathDifferentiator:(NSString*)tagPath;
+ (NSMutableString*)tagPathCombinar:(NSMutableArray*)returnArray;
- (BOOL)match:(EMVTLV*)tlv;
@end
