Conforming to http://www.openscdp.org/scripts/tutorial/emv/TLV.html;
Tested on Miura Payment System.

Main method.
//from TLV raw NSData to TLV Class Instance.
+ (EMVTLV*)unserialise:(NSData*)responseData;

//from TLV Class Instance to TLV raw NSData.
- (NSMutableData*) serialise;  
