#import <Foundation/Foundation.h>

@interface USGlobals : NSObject {
	NSMutableDictionary *wsdlStandardNamespaces;
}

@property (retain) NSMutableDictionary *wsdlStandardNamespaces;

+ (USGlobals *)sharedInstance;

@end