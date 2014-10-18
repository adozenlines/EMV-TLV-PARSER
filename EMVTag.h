//
//  EMVTag.h
//
//  Created by Damon Yuan on 8/6/14.
//

#import <Foundation/Foundation.h>

@interface EMVTag : NSObject
@property (nonatomic, strong) NSData* tagData;

- (instancetype)initWithTag:(NSData *)tagData;
- (BOOL)constructed;
- (NSString*)description;
- (NSString* )serialiseTag;
- (NSString*)_descriptionForKey:(NSString*)key;

+ (EMVTag*)tagLookup:(NSString*)description;
@end
