//
//  Tag.m
//  TLV parser
//
//  Created by Damon Yuan on 2/3/14.
//  Copyright (c) 2014 Damon Yuan. All rights reserved.
//

#import "Tag.h"

@implementation Tag
//argument tagData can be nsdata or nsstring.
- (instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}
- (instancetype)initWithTag:(id)tagData
{
    self = [super init];
    if (self) {
        if (([tagData class] == [NSData class])||([[tagData class] isSubclassOfClass:[NSData class]])) {
            self.tagData = [NSData dataWithData:tagData];
        }
        if (([tagData class] == [NSString class])||([[tagData class]isSubclassOfClass:[NSString class]])) {
            self.tagData = [self stringToData:tagData];
        }
    }
    return self;
}

-(BOOL)constructed
{
    Byte buf;
    NSRange range = NSMakeRange(0, 1);
    [self.tagData getBytes:&buf range:range];
    return ((buf & 0x20) == 0x20);
}

//string from nsdata
- (NSString* )serialise
{
    NSData *data = self.tagData;
    NSUInteger capacity = data.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
    }
    NSMutableString *temp = [NSMutableString stringWithString:@"0x"];
    [temp appendString:sbuf];
    
    return [NSString stringWithString:temp];
}
//string to data
- (NSData*)stringToData:(NSString*)command
{
    command = [command stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([command length] / 2); i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    //NSLog(@"Damon: Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, commandToSend);
    return [NSData dataWithData:commandToSend];
}

//get the description based on the tag
- (NSString*)description
{
    NSString* tagString = [self serialise];
    return [[self _getDescriptions] valueForKey:tagString];
}

//get the tag object based on the description
- (Tag*)tagLookup:(NSString*)description
{
    NSArray* a = [[self _getDescriptions] allKeysForObject:description];
    if ([a count]==0) {
        NSLog(@"Damon: Logging %@ in %@: %@", NSStringFromSelector(_cmd), self, @"No Tag for this description");
        return nil;
    }
    if ([a count] == 1) {
        Tag* tag = [[Tag alloc]initWithTag:[a objectAtIndex:0]];
        return tag;
    }
    return nil;
}

- (NSString*)_descriptionForKey:(NSString*)key
{
    NSString* _key = [key lowercaseString];
    return [[self _getDescriptions] valueForKey:_key];
}

- (NSDictionary*)_getDescriptions
{
    NSDictionary* descriptions = [[NSMutableDictionary alloc]init];
    [descriptions setValue:@"Card Status" forKey:@"0x48"];
    [descriptions setValue:@"AID" forKey:@"0x4f"];
    [descriptions setValue:@"Application Label" forKey:@"0x50"];
    [descriptions setValue:@"Track 2 Equivalent Data" forKey:@"0x57"];
    [descriptions setValue:@"Application Primary Account Number (PAN)" forKey:@"0x5a"];
    [descriptions setValue:@"Cardholder Name" forKey:@"0x5f20"];
    [descriptions setValue:@"Language Preference" forKey:@"0x5f2d"];
    [descriptions setValue:@"Application Expiration Date" forKey:@"0x5f24"];
    [descriptions setValue:@"Application Effective Date" forKey:@"0x5f25"];
    [descriptions setValue:@"Issuer Country Code" forKey:@"0x5f28"];
    [descriptions setValue:@"Transaction Currency Code" forKey:@"0x5f2a"];
    [descriptions setValue:@"Service Code" forKey:@"0x5f30"];
    [descriptions setValue:@"Application Primary Account Number (PAN) Sequence Number" forKey:@"0x5f34"];
    [descriptions setValue:@"Transaction Currency Exponent" forKey:@"0x5f36"];
    [descriptions setValue:@"Application Template" forKey:@"0x61"];
    [descriptions setValue:@"FCI Template" forKey:@"0x6f"];
    [descriptions setValue:@"Read Record response" forKey:@"0x70"];
    [descriptions setValue:@"Response Message Template Format 2" forKey:@"0x77"];
    [descriptions setValue:@"Response Message Template Format 1" forKey:@"0x80"];
    [descriptions setValue:@"Amount, Authorised (Binary)" forKey:@"0x81"];
    [descriptions setValue:@"Application Interchange Profile" forKey:@"0x82"];
    [descriptions setValue:@"DF Name" forKey:@"0x84"];
    [descriptions setValue:@"Issuer Script Command" forKey:@"0x86"];
    [descriptions setValue:@"Application Priority Indicator" forKey:@"0x87"];
    [descriptions setValue:@"SFI" forKey:@"0x88"];
    [descriptions setValue:@"Authorisation Response Code" forKey:@"0x8a"];
    [descriptions setValue:@"Card Risk Management Data Object List 1 (CDOL1)" forKey:@"0x8c"];
    [descriptions setValue:@"Card Risk Management Data Object List 2 (CDOL2)" forKey:@"0x8d"];
    [descriptions setValue:@"Cardholder Verification Method (CVM) List" forKey:@"0x8e"];
    [descriptions setValue:@"Certification Authority Public Key Index" forKey:@"0x8f"];
    [descriptions setValue:@"Issuer Public Key Certificate" forKey:@"0x90"];
    [descriptions setValue:@"Issuer Public Key Remainder" forKey:@"0x92"];
    [descriptions setValue:@"Signed Static Application Data" forKey:@"0x93"];
    [descriptions setValue:@"Application File Locator (AFL)" forKey:@"0x94"];
    [descriptions setValue:@"Terminal Verification Results" forKey:@"0x95"];
    [descriptions setValue:@"Transaction Certificate Data Object List (TDOL)" forKey:@"0x97"];
    [descriptions setValue:@"Transaction Status Information" forKey:@"0x9b"];
    [descriptions setValue:@"Transaction Type" forKey:@"0x9c"];
    [descriptions setValue:@"Transaction Information Status sale" forKey:@"0x9c00"];
    [descriptions setValue:@"Transaction Information Status cash" forKey:@"0x9c01"];
    [descriptions setValue:@"Transaction Information Status cashback" forKey:@"0x9c09"];
    [descriptions setValue:@"Acquirer Identifier" forKey:@"0x9f01"];
    [descriptions setValue:@"Amount, Authorised (Numeric)" forKey:@"0x9f02"];
    [descriptions setValue:@"Amount, Other (Numeric)" forKey:@"0x9f03"];
    [descriptions setValue:@"Amount, Other (Binary)" forKey:@"0x9f04"];
    [descriptions setValue:@"Application Discretionary Data" forKey:@"0x9f05"];
    [descriptions setValue:@"Application Identifier (AID) - terminal" forKey:@"0x9f06"];
    [descriptions setValue:@"Application Usage Control" forKey:@"0x9f07"];
    [descriptions setValue:@"ICC Application Version Number" forKey:@"0x9f08"];
    [descriptions setValue:@"Term Application Version Number" forKey:@"0x9f09"];
    [descriptions setValue:@"Cardholder Name Extended" forKey:@"0x9f0b"];
    [descriptions setValue:@"Issuer Action Code - Default" forKey:@"0x9f0d"];
    [descriptions setValue:@"Issuer Action Code - Denial" forKey:@"0x9f0e"];
    [descriptions setValue:@"Issuer Action Code - Online" forKey:@"0x9f0f"];
    [descriptions setValue:@"Issuer Application Data" forKey:@"0x9f10"];
    [descriptions setValue:@"Issuer Code Table Index" forKey:@"0x9f11"];
    [descriptions setValue:@"Application Preferred Name" forKey:@"0x9f12"];
    [descriptions setValue:@"Last Online Application Transaction Counter (ATC) Register" forKey:@"0x9f13"];
    [descriptions setValue:@"Lower Consecutive Offline Limit" forKey:@"0x9f14"];
    [descriptions setValue:@"Personal Identification Number (PIN) Try Counter" forKey:@"0x9f17"];
    [descriptions setValue:@"Terminal Country Code" forKey:@"0x9f1a"];
    [descriptions setValue:@"Terminal Floor Limit" forKey:@"0x9f1b"];
    [descriptions setValue:@"Terminal ID" forKey:@"0x9f1c"];
    [descriptions setValue:@"Interface Device Serial Number" forKey:@"0x9f1e"];
    [descriptions setValue:@"Track 1 Discretionary Data" forKey:@"0x9f1f"];
    [descriptions setValue:@"Track 2 Discretionary Data" forKey:@"0x9f20"];
    [descriptions setValue:@"Upper Consecutive Offline Limit" forKey:@"0x9f23"];
    [descriptions setValue:@"Application Cryptogram" forKey:@"0x9f26"];
    [descriptions setValue:@"Cryptogram Information Data" forKey:@"0x9f27"];
    [descriptions setValue:@"ICC PIN Encipherment Public Key Certificate" forKey:@"0x9f2d"];
    [descriptions setValue:@"ICC PIN Encipherment Public Key Exponent" forKey:@"0x9f2e"];
    [descriptions setValue:@"ICC PIN Encipherment Public Key Remainder" forKey:@"0x9f2f"];
    [descriptions setValue:@"Issuer Public Key Exponent" forKey:@"0x9f32"];
    [descriptions setValue:@"Terminal Capabilities" forKey:@"0x9f33"];
    [descriptions setValue:@"Cardholder Verification Method (CVM) Results" forKey:@"0x9f34"];
    [descriptions setValue:@"Terminal Type" forKey:@"0x9f35"];
    [descriptions setValue:@"Application Transaction Counter (ATC)" forKey:@"0x9f36"];
    [descriptions setValue:@"Unpredictable Number" forKey:@"0x9f37"];
    [descriptions setValue:@"Processing Options Data Object List (PDOL)" forKey:@"0x9f38"];
    [descriptions setValue:@"Application Reference Currency" forKey:@"0x9f3b"];
    [descriptions setValue:@"Terminal Capabilities Add'l" forKey:@"0x9f40"];
    [descriptions setValue:@"Application Currency Code" forKey:@"0x9f42"];
    [descriptions setValue:@"Application Reference Currency Exponent" forKey:@"0x9f43"];
    [descriptions setValue:@"Application Currency Exponent" forKey:@"0x9f44"];
    [descriptions setValue:@"ICC Public Key Certificate" forKey:@"0x9f46"];
    [descriptions setValue:@"ICC Public Key Exponent" forKey:@"0x9f47"];
    [descriptions setValue:@"ICC Public Key Remainder" forKey:@"0x9f48"];
    [descriptions setValue:@"Dynamic Data Authentication Data Object List (DDOL)" forKey:@"0x9f49"];
    [descriptions setValue:@"Static Data Authentication Tag List" forKey:@"0x9f4a"];
    [descriptions setValue:@"Signed Dynamic Application Data" forKey:@"0x9f4b"];
    [descriptions setValue:@"ICC Dynamic Number" forKey:@"0x9f4c"];
    [descriptions setValue:@"Issuer Script Results" forKey:@"0x9f5b"];
    [descriptions setValue:@"FCI Proprietary Template" forKey:@"0xa5"];
    [descriptions setValue:@"File Control Information (FCI) Issuer Discretionary Data" forKey:@"0xbf0c"];
    [descriptions setValue:@"Decision" forKey:@"0xc0"];
    [descriptions setValue:@"Acquirer Index" forKey:@"0xc2"];
    [descriptions setValue:@"Status Code" forKey:@"0xc3"];
    [descriptions setValue:@"Status Text" forKey:@"0xc4"];
    [descriptions setValue:@"PIN Retry Counter" forKey:@"0xc5"];
    [descriptions setValue:@"Identifier" forKey:@"0xdf0d"];
    [descriptions setValue:@"Cardholder Verification Status" forKey:@"0xdf28"];
    [descriptions setValue:@"Version" forKey:@"0xdf7f"];
    [descriptions setValue:@"Command Data" forKey:@"0xe0"];
    [descriptions setValue:@"Response Data" forKey:@"0xe1"];
    [descriptions setValue:@"Decision Required" forKey:@"0xe2"];
    [descriptions setValue:@"Transaction Approved" forKey:@"0xe3"];
    [descriptions setValue:@"Online Authorisation Required" forKey:@"0xe4"];
    [descriptions setValue:@"Transaction Declined" forKey:@"0xe5"];
    [descriptions setValue:@"Terminal Status Changed" forKey:@"0xe6"];
    [descriptions setValue:@"Configuration Information" forKey:@"0xed"];
    [descriptions setValue:@"Software Information" forKey:@"0xef"];
    [descriptions setValue:@"Terminal Action Code DEFAULT" forKey:@"0xff0d"];
    [descriptions setValue:@"Terminal Action Code OFFLINE" forKey:@"0xff0e"];
    [descriptions setValue:@"Terminal Action Code ONLINE" forKey:@"0xff0f"];
    [descriptions setValue:@"PIN Digit Status" forKey:@"0xdfa201"];
    [descriptions setValue:@"PIN Entry Status" forKey:@"0xdfa202"];
    [descriptions setValue:@"Configure TRM Stage" forKey:@"0xdfa203"];
    [descriptions setValue:@"Configure Application Selection" forKey:@"0xdfa204"];
    [descriptions setValue:@"Keyboard Data" forKey:@"0xdfa205"];
    [descriptions setValue:@"Secure Prompt" forKey:@"0xdfa206"];
    [descriptions setValue:@"Number Format" forKey:@"0xdfa207"];
    [descriptions setValue:@"Numeric Data" forKey:@"0xdfa208"];
    [descriptions setValue:@"Battery Data" forKey:@"0xdfa209"];
    [descriptions setValue:@"Stream Offset" forKey:@"0xdfa301"];
    [descriptions setValue:@"Stream Size" forKey:@"0xdfa302"];
    [descriptions setValue:@"Stream timeout" forKey:@"0xdfa303"];
    [descriptions setValue:@"File md5sum" forKey:@"0xdfa304"];
    [descriptions setValue:@"P2PE Status" forKey:@"0xdfae01"];
    [descriptions setValue:@"SRED Data" forKey:@"0xdfae02"];
    [descriptions setValue:@"SRED KSN" forKey:@"0xdfae03"];
    [descriptions setValue:@"Online PIN Data" forKey:@"0xdfae04"];
    [descriptions setValue:@"Online PIN KSN" forKey:@"0xdfae05"];
    [descriptions setValue:@"Masked Track 2" forKey:@"0xdfae22"];
    [descriptions setValue:@"ICC Masked Track 2" forKey:@"0xdfae57"];
    [descriptions setValue:@"Masked PAN" forKey:@"0xdfae5A"];
    [descriptions setValue:@"Transaction Info Status bits" forKey:@"0xdfdf00"];
    [descriptions setValue:@"Revoked certificates list" forKey:@"0xdfdf01"];
    [descriptions setValue:@"Online DOL" forKey:@"0xdfdf02"];
    [descriptions setValue:@"Referral DOL" forKey:@"0xdfdf03"];
    [descriptions setValue:@"ARPC DOL" forKey:@"0xdfdf04"];
    [descriptions setValue:@"Reversal DOL" forKey:@"0xdfdf05"];
    [descriptions setValue:@"AuthResponse DO" forKey:@"0xdfdf06"];
    [descriptions setValue:@"PSE Directory" forKey:@"0xdfdf09"];
    [descriptions setValue:@"Threshold Value for Biased Random Selection" forKey:@"0xdfdf10"];
    [descriptions setValue:@"Target Percentage for Biased Random Selection" forKey:@"0xdfdf11"];
    [descriptions setValue:@"Maximum Target Percentage for Biased Random Selection" forKey:@"0xdfdf12"];
    [descriptions setValue:@"Default CVM" forKey:@"0xdfdf13"];
    [descriptions setValue:@"Issuer script size limit" forKey:@"0xdfdf16"];
    [descriptions setValue:@"Log DOL" forKey:@"0xdfdf17"];
    [descriptions setValue:@"Partial AID Selection Allowed" forKey:@"0xe001"];
    return descriptions;
}






@end
