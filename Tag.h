//
//  Tag.h
//  TLV parser
//
//  Created by Damon Yuan on 2/3/14.
//  Copyright (c) 2014 Damon Yuan. All rights reserved.
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
