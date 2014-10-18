//
//  EMVTLV.h
//
//  Created by Damon Yuan on 8/6/14.
//

#import "EMVTLV.h"
#import "EMVTag.h"
#import "EMVTLVTagComparitor.h"
@interface EMVTLV()

@end

@implementation EMVTLV

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.prefix = nil;
        self.objects = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype)initWithTag:(EMVTag*)tag Value:(NSObject*)value
{
    self = [super init];
    if (self) {
        self.prefix = nil;
        self.objects = [[NSMutableArray alloc] init];
        
        if ([value class] == [NSData class]||[value class] == [EMVTLV class]||[[value class]isSubclassOfClass:[NSData class]]||[[value class]isSubclassOfClass:[EMVTLV class]]) {
            [self.objects addObject:[NSArray arrayWithObjects:tag, value, nil]];
        }else{
            NSAssert(FALSE, @"Not NSData or MiuraTLV");
        }
    }
    return self;
}

// Uses built-in len() function to return the count of TLV items storedby the TLV instance.
// Note: if any items are constructed, sub-items are not included in this count.
- (int)__len__
{
    return [self.objects count];
}

// There are two possible return type: NSData or MiuraTLV
- (instancetype)__getitem__:(NSUInteger)index
{
    if ([self __len__]>index) {
        return [self.objects objectAtIndex:index];
    }
    return nil;
}

- (BOOL)empty
{
    return [self.objects count] == 0;
}

- (EMVTag*)firstTag
{
    if ([self.objects count]>0) {
        return [[self.objects objectAtIndex:0] objectAtIndex:0];
    }
    return nil;
}

// Returns a list of all the Tag items in this TLV.  Note: tags from inner constructed items are not included.  If asInts is True then the returned list contains integers converted from the Tag objects.
- (NSArray*)tags
{
    if ([self empty] == false) {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        for (id object in self.objects) {
            TagValueCouple* temp = (TagValueCouple*)object;
            [result addObject:[temp objectAtIndex:0]];
        }
        return result;
    }
    return nil;
}

- (void)append:(EMVTag*)tag Value:(NSObject*)value
{
    if (([value class] != [NSData class]) && ([value class] != [EMVTLV class])&&(![[value class]isSubclassOfClass:[NSData class]])&&(![[value class]isSubclassOfClass:[EMVTLV class]])) {
        NSAssert(FALSE, @"Not NSData or MiuraTLV");
    }else{
        TagValueCouple* tag_data = [NSArray arrayWithObjects:tag,value, nil];
        [self.objects addObject:tag_data];
    }
}

- (void)extend:(EMVTLV*)tlv
{
    for (id object in tlv.objects) {
        TagValueCouple* temp  = (TagValueCouple*)object;
        [self append:[temp objectAtIndex:0] Value:[temp objectAtIndex:1]];
    }
}

- (NSMutableData*) serialise
{
    NSMutableData* formattedTlvData = [[NSMutableData alloc] init];
    for (id object in self.objects) {
        TagValueCouple* tag_value = (TagValueCouple*)object;
        NSData *tagData = [(EMVTag *)[tag_value objectAtIndex:0] tagData];
        [formattedTlvData appendData:tagData];
        NSData* tempData;
        if ([[tag_value objectAtIndex:1] class] == [NSData class]||[[[tag_value objectAtIndex:1]class]isSubclassOfClass:[NSData class]]) {
            tempData = [tag_value objectAtIndex:1];
        }else if ([[tag_value objectAtIndex:1]class] == [EMVTLV class]||[[[tag_value objectAtIndex:1]class]isSubclassOfClass:[EMVTLV class]]){
            tempData = [[tag_value objectAtIndex:1] serialise];
        }else{
            NSAssert(FALSE, @"Not NSData or MiuraTLV");
        }
        UInt8 lenBytes = 0;
        if (tempData.length>=128) {
            lenBytes+=1;
        }
        if (tempData.length>=256) {
            lenBytes+=1;
        }
        if (lenBytes>0) {
            Byte buf = 0x80 + lenBytes;
            [formattedTlvData appendBytes:&buf length:1];
            //tempData.length
            Byte bytes[100];
            for (int i=0; i<lenBytes; i++)
            {
                bytes[lenBytes-1-i] = ((tempData.length >> (8*i))&0xff);
            }
            [formattedTlvData appendBytes:&bytes length:lenBytes];
        }else{
            Byte buf = tempData.length;
            [formattedTlvData appendBytes:&buf length:1];
        }
        [formattedTlvData appendData:tempData];
    }
    return formattedTlvData;
}

// Returns the first value that matches the tagPath.  Returns None ifthere is no match.  Note that a value return of "" (empty string)means a match *is* found (albeit 0 length).
// The returned type can be NSData (primitive type) or MiuraTLV(constructed type)
- (instancetype)firstMatch:(NSString*)tagPath
{
    NSMutableArray* matches = [self _search:tagPath];
    if ([matches count]>0) {  //More than one tag_value pair is found
        return [matches objectAtIndex:0];
    }
    return nil;
}
- (NSMutableArray*)_search:(NSString*)tagPath
{
    NSMutableArray* values = [[NSMutableArray alloc] init];
    NSMutableArray* tagPathArray = [EMVTLVTagComparitor tagPathDifferentiator:tagPath];
    NSString* head = [tagPathArray objectAtIndex:0];
    [tagPathArray removeObjectAtIndex:0]; //this is then the tail
    NSString* tail = [EMVTLVTagComparitor tagPathCombinar:tagPathArray];
    if (![self empty]) {
        for (id object in self.objects) {
            TagValueCouple* temp = (TagValueCouple*)object;
            if ([[[temp objectAtIndex:0] serialiseTag] isEqualToString:head]) {
                if (([tagPathArray count]>0) && ([[temp objectAtIndex:1]class] == [EMVTLV class]||[[[temp objectAtIndex:1]class]isSubclassOfClass:[EMVTLV class]])) {
                    for (id obj in [[temp objectAtIndex:1]_search:tail]) {
                        [values addObject:obj];
                    }
                }else if([tagPathArray count]==0){
                    [values addObject:[temp objectAtIndex:1]];
                }
            }
        }
    }
    return values;
}

#pragma common method
+ (TagValueCouple*)getTag:(NSData*)data
{
    EMVTag* tag;
    Byte* dataBytes = (Byte*)[data bytes];
    
    if (data.length<1) {
        return [TagValueCouple arrayWithObjects:nil,nil, nil];
    }
    tag = [[EMVTag alloc]initWithTag:[NSData dataWithBytes:dataBytes length:1]];
    if ((dataBytes[0]&0x1f)==0x1f) {
        for (int i =1; i<data.length; i++) {
            tag = [[EMVTag alloc] initWithTag:[NSData dataWithBytes:dataBytes length:i+1]];
            if ((dataBytes[i]&0x80)!=0x80) {
                break;
            }
        }
    }
    
    // Gets a TLV "tag" from data and returns it as a Tag object along with the data remaining after the tag element is removed.
    return [TagValueCouple arrayWithObjects:tag,[NSData dataWithBytes:&dataBytes[tag.tagData.length] length:data.length-tag.tagData.length], nil];
}

+ (LengthValueCouple*)getLength:(NSData*)dataFromGetTag
{
    NSNumber* len = [NSNumber numberWithInt:0];
    UInt8 lenBytes = 1;
    
    Byte* dataBytes = (Byte*)[dataFromGetTag bytes];
    
    if (dataFromGetTag.length <1) {
        len =[NSNumber numberWithInt:-1];
        return [LengthValueCouple arrayWithObjects:len,nil, nil];
    }
    if ((dataBytes[0]&0x80)==0x80) {
        lenBytes = lenBytes + dataBytes[0]&0x7f;
        NSUInteger lenInt = 0;
        for (int i = 1; i<lenBytes; i++) {
            UInt8 temp = dataBytes[i];
            lenInt = lenInt*16*16+temp;
        }
        len = [NSNumber numberWithInt:lenInt];
    }else{
        UInt8 temp_len = dataBytes[0]&0x7f;
        len = [NSNumber numberWithInt:temp_len];
    }
    
    // Gets a TLV "length" from data and returns it as an integer along with the data remaining after the length element is removed.
    return [LengthValueCouple arrayWithObjects:len,[NSData dataWithBytes:dataBytes+lenBytes length:dataFromGetTag.length-lenBytes], nil];
}

+ (EMVTLV*)unserialise:(NSData*)responseData   //data without sw1sw2
{
    @try{
        EMVTLV* TLV_result = [[EMVTLV alloc] init];
        NSInteger length = 0;
        //NSData* _responseData = responseData;
        
        while (length>=0 && responseData.length>0)
        {
            TagValueCouple* tag_data = [self getTag:responseData];
            LengthValueCouple* length_data = [self getLength:[tag_data objectAtIndex:1]];
            EMVTag* tag = [tag_data objectAtIndex:0];
            
            NSData* rawData = [length_data objectAtIndex:1];
            Byte* bytes = (Byte*)[rawData bytes];
            NSNumber* len = [length_data objectAtIndex:0];
            length = [len integerValue];; //would be -1 if dataFromGetTag.length < 1(only have Tag in TLV).
            
            if (tag) {
                if ([tag constructed]) {
                    NSData* valueForTag = [NSData dataWithBytes:bytes length:length];
                    responseData = [NSData dataWithBytes:bytes+length length:rawData.length-length];
                    [TLV_result append:tag Value:[self unserialise:valueForTag]];
                }else{
                    NSData* valueForTag = [NSData dataWithBytes:bytes length:length];
                    responseData = [NSData dataWithBytes:bytes+length length:rawData.length-length];
                    [TLV_result append:tag Value:valueForTag];
                }
            }
        }
        return TLV_result;

    }
    @catch (NSException *exception) {
         BPLogDebug(@"Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, exception);
    }
}

@end
