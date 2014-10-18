//
//  NSData+HexNSString.h
//
//  Created by Damon Yuan on 8/6/14.
//

#import <Foundation/Foundation.h>

@interface NSData (HexNSString)
- (NSString*)hexRepresentationWithSpaces_AS:(BOOL)spaces;
+ (NSData*)hexStringToData:(NSString*)string;
@end
