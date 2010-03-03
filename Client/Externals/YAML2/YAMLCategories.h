//
//  YAMLCategories.h
//  YAML
//
//  Created by William Thimbleby on Sat Sep 25 2004.
//  Copyright (c) 2004 William Thimbleby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAMLWrapper : NSObject
{
	Class tag;
	id data;
}
+ (id)wrapperWithData:(id)d tag:(Class)cn;
- (id)initWrapperWithData:(id)d tag:(Class)cn;
- (id)data;
- (Class)tag;
@end

@interface NSString (YAMLAdditions)

+ (id)stringWithUTF8String:(const char *)bytes length:(unsigned)length;
-(int) indent;
-(NSString*) indented:(int)indent;
-(NSString*) trim;
-(NSString*) firstWord;
-(id) logicalValue;
-(NSString*)yamlDescriptionWithIndent:(int)indent;

@end

@interface NSArray (YAMLAdditions)
-(NSString*) yamlDescriptionWithIndent:(int)indent;
- (id)firstObject;
- (NSArray*)collectWithSelector:(SEL)aSelector withObject:(id)anObject;
- (NSArray*)collectWithSelector:(SEL)aSelector;
@end

@interface NSDictionary (YAMLAdditions)
-(NSString*) yamlDescriptionWithIndent:(int)indent;
- (NSDictionary*)collectWithSelector:(SEL)aSelector withObject:(id)anObject;
- (NSDictionary*)collectWithSelector:(SEL)aSelector;
@end

@interface NSObject (YAMLAdditions)
-(id) toYAML;
-(NSString*) yamlDescription;
-(NSString*) yamlDescriptionWithIndent:(int)indent;
- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array;
- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set;
@end
