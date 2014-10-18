//
//  EMVTLV.h
//
//  Created by Damon Yuan on 8/6/14.
//

typedef NSArray                      TagValueCouple;
typedef NSArray                      LengthValueCouple;
#import <Foundation/Foundation.h>

@class EMVTag;

@interface EMVTLV : NSObject
@property (nonatomic, strong) NSString* prefix;
@property (nonatomic, strong) NSMutableArray* objects;

- (instancetype)initWithTag:(EMVTag*)tag Value:(NSObject*)value;
- (int)__len__;
- (instancetype)__getitem__:(NSUInteger)index;
- (BOOL)empty;
- (EMVTag*)firstTag;
- (NSArray*)tags;
- (void)extend:(EMVTLV*)tlv;
- (void)append:(EMVTag*)tag Value:(NSObject*)value;
- (NSMutableArray*) _search:(NSString*)tagPath;
- (instancetype)firstMatch:(NSString*)tagPath;

+ (EMVTLV*)unserialise:(NSData*)responseData;
- (NSMutableData*) serialise;
@end
