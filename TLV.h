//
//  TLV.h
//
//  Created by Damon Yuan on 8/6/14.
//  All rights reserved.
//
typedef NSArray                      TagValueCouple;
typedef NSArray                      LengthValueCouple;
#import <Foundation/Foundation.h>

@class Tag;

@interface TLV : NSObject
@property (nonatomic, strong) NSString* prefix;
//TLV tagValue couple is stored here.
@property (nonatomic, strong) NSMutableArray* objects;


-(instancetype)initWithTag:(Tag*)tag Value:(NSObject*)value;
//- (void)append:(Tag*)tag Value:(NSObject*)value;
- (int)__len__;
- (instancetype)__getitem__:(NSUInteger)index;
- (BOOL)empty;
- (Tag*)firstTag;
- (NSArray*)tags;
- (void)extend:(TLV*)tlv;
- (void)append:(Tag*)tag Value:(NSObject*)value;

+ (TLV*)unserialise:(NSData*)responseData;
+ (NSMutableData*) serialise: (TLV*)tlv;
- (NSMutableArray*) _search:(NSString*)tagPath;
- (instancetype)firstMatch:(NSString*)tagPath;
@end
