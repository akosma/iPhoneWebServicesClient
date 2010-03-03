#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import "ns1.h"
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "datawsdl.h"
#import "ns1.h"
@class datawsdlBinding;
@interface datawsdl : NSObject {
	
}
+ (datawsdlBinding *)datawsdlBinding;
@end
@class datawsdlBindingResponse;
@class datawsdlBindingOperation;
@protocol datawsdlBindingResponseDelegate <NSObject>
- (void) operation:(datawsdlBindingOperation *)operation completedWithResponse:(datawsdlBindingResponse *)response;
@end
@interface datawsdlBinding : NSObject <datawsdlBindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(datawsdlBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (datawsdlBindingResponse *)lookupUsingLimit:(NSNumber *)aLimit ;
- (void)lookupAsyncUsingLimit:(NSNumber *)aLimit  delegate:(id<datawsdlBindingResponseDelegate>)responseDelegate;
@end
@interface datawsdlBindingOperation : NSOperation {
	datawsdlBinding *binding;
	datawsdlBindingResponse *response;
	id<datawsdlBindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) datawsdlBinding *binding;
@property (readonly) datawsdlBindingResponse *response;
@property (nonatomic, assign) id<datawsdlBindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(datawsdlBinding *)aBinding delegate:(id<datawsdlBindingResponseDelegate>)aDelegate;
@end
@interface datawsdlBinding_lookup : datawsdlBindingOperation {
	NSNumber * limit;
}
@property (retain) NSNumber * limit;
- (id)initWithBinding:(datawsdlBinding *)aBinding delegate:(id<datawsdlBindingResponseDelegate>)aDelegate
	limit:(NSNumber *)aLimit
;
@end
@interface datawsdlBinding_envelope : NSObject {
}
+ (datawsdlBinding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface datawsdlBindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
