#import "USGlobals.h"

USGlobals *sharedInstance = nil;

@implementation USGlobals

@synthesize wsdlStandardNamespaces;

+ (USGlobals *)sharedInstance
{
	if(sharedInstance == nil) {
		sharedInstance = [[USGlobals alloc] init];
	}
	
	return sharedInstance;
}

- (id)init
{
	if((self = [super init])) {
		wsdlStandardNamespaces = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

@end
