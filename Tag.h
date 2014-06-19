//
//  Tag.h
//
//  Created by Damon Yuan on 8/6/14.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Tag : NSObject
@property (nonatomic, strong) NSData* tagData;

- (instancetype)initWithTag:(id)tagData;
-(BOOL)constructed;
- (NSString*)description;
- (Tag*)tagLookup:(NSString*)description;
- (NSString* )serialise;
- (NSData*)stringToData:(NSString*)command;
- (Tag*)tagLookup:(NSString*)description;
- (NSString*)_descriptionForKey:(NSString*)key;
@end
