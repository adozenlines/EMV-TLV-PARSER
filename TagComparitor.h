//
//  TagComparitor.h
//  TLV parser
//
//  Created by Damon Yuan on 2/3/14.
//  Copyright (c) 2014 Damon Yuan. All rights reserved.
//
typedef NSArray                      TagValueCouple;
typedef NSArray                      LengthValueCouple;
#import <Foundation/Foundation.h>

@class TLV;
@class Tag;
@interface TagComparitor : NSObject

- (instancetype)initWithArgs:(id)_args;
- (Tag*)tagLookup:(NSString*)description;
+ (NSMutableArray*)tagPathDifferentiator:(NSString*)tagPath;
+ (NSMutableString*)tagPathCombinar:(NSMutableArray*)returnArray;
- (BOOL)match:(TLV*)tlv;
@end
