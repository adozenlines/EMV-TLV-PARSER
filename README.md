EMV-TLV-PARSER
==============

EMV TLV PARSER

#What is this?

TLV data formmat parser for EMV transaction. 
Conforming to http://www.openscdp.org/scripts/tutorial/emv/TLV.html.
Tested on Miura Payment System.
Hope it helps.

#How to use it?

Import EMVTLV to your project.

Main methods.
//from TLV raw NSData to TLV Class Instance.
+ (EMVTLV*)unserialise:(NSData*)responseData;

//from TLV Class Instance to TLV raw NSData.
- (NSMutableData*) serialise;  

Others
// Init a TLV with tag and its value
- (instancetype)initWithTag:(EMVTag*)tag Value:(NSObject*)value;

// Return number of tag-value couple.
- (int)__len__;

// Return the tag-value couple at the position of index
- (instancetype)__getitem__:(NSUInteger)index;

// Check if the EMVTLV instance is empty
- (BOOL)empty;

// Get the first tag in the EMVTLV instance
- (EMVTag*)firstTag;

// Get all the tags in eht EMVTLV instance
- (NSArray*)tags;

// Append a TLV tag-value couple at the end of a EMVTLV instance
- (void)extend:(EMVTLV*)tlv;
- (void)append:(EMVTag*)tag Value:(NSObject*)value;

// Search and return all the tag-value couples under a tagPath
- (NSMutableArray*) _search:(NSString*)tagPath;

// Search and return the first tag-value couple under a tagPath
- (instancetype)firstMatch:(NSString*)tagPath;
