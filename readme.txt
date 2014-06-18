Conforming to http://www.openscdp.org/scripts/tutorial/emv/TLV.html;
Main method.
//from TLV raw NSData to TLV Class Instance.
+ (TLV*)unserialise:(NSData*)responseData; 

//from TLV Class Instance to TLV raw NSData.
+ (NSMutableData*) serialise: (TLV*)tlv;   