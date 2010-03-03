//
//  YAMLCategories.m
//  YAML
//
//  Created by William Thimbleby on Sat Sep 25 2004.
//  Copyright (c) 2004 William Thimbleby. All rights reserved.
//

#import "YAMLCategories.h"
#import "YAMLCocoaCategories.h"

BOOL yamlClass(id object)
{
	if([object isKindOfClass:[NSArray class]])
		return YES;
	if([object isKindOfClass:[NSDictionary class]])
		return YES;
	if([object isKindOfClass:[NSString class]])
		return YES;
	if([object isKindOfClass:[NSNumber class]])
		return YES;
	return NO;
}

@implementation YAMLWrapper

+ (id)wrapperWithData:(id)d tag:(Class)cn
{
	return [[[YAMLWrapper alloc] initWrapperWithData:d tag:cn] autorelease];
}

- (id)initWrapperWithData:(id)d tag:(Class)cn
{
	self = [super init];
	data = [d retain];
	tag = cn;
	return self;
}

- (void)dealloc
{
	[data release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	YAMLWrapper *w = [YAMLWrapper allocWithZone:zone];
	
	[w initWrapperWithData:data tag:tag];
	
	return [w autorelease];
}

- (id)data
{
	return data;
}

- (Class)tag
{
	return tag;
}

- (id)yamlParse
{
	NSLog(@"%@-%@",tag,data);
	return [tag objectWithYAML:data];
}

@end

#pragma mark -

@implementation NSString (YAMLAdditions)

+ (id)stringWithUTF8String:(const char *)bytes length:(unsigned)length
{
	NSString *str = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
	
	return [str autorelease];
}

-(int) indent
{
	int i;
	//calculate the indent
	i = 0;
	while(i < [self length] && [self characterAtIndex:i] == ' ')
		i = i+1;
	
	return i;
}

-(NSString*) indented:(int)indent
{
	NSRange				lineRange;
	int					i = [self length]-1;
	NSMutableString		*indented = [NSMutableString stringWithString:self];
	
	NSString			*stringIndent;
	char				*strIndent = malloc(indent+1);
	
	memset(strIndent, ' ', indent);
	strIndent[indent] = 0;
	
	stringIndent = [NSString stringWithCString:strIndent encoding:NSUTF8StringEncoding];
	
	while(i > 0)
	{
		lineRange = [indented lineRangeForRange:NSMakeRange(i,0)];
		
		[indented insertString:stringIndent atIndex:lineRange.location];
		
		i = lineRange.location - 1;
	}
	
	return indented;
}

-(NSString*) trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString*) firstWord
{
	NSRange space = [self rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if(space.location == NSNotFound)
		space.location = [self length];
		
	return [self substringWithRange:NSMakeRange(0,space.location)];
}

-(id) logicalValue
{
	return self;
}

-(NSString*)yamlDescriptionWithIndent:(int)indent
{
	NSRange		lineRange;
	
	lineRange = [self lineRangeForRange:NSMakeRange(0,0)];
	
	//if no line breaks in string
	if(lineRange.length >= [self length])
		return self;
	
	return [NSString stringWithFormat:@"|-\n%@", [self indented:indent]];
}

-(BOOL) boolValue
{
	return [self intValue];
}

- (id)toYAML
{
	return self;
}

@end

@implementation NSArray (YAMLAdditions)

-(NSArray*) yamlData
{
	NSEnumerator		*enumerator;
	id			object;
	
	NSMutableArray		*array = [NSMutableArray array];
	
	//output
	enumerator = [self objectEnumerator];
	while (object = [enumerator nextObject])
	{
		/*if(!yamlClass(object))
		{
			[array addObject:[YAMLWrapper wrapperWithData:[object yamlData] tag:[object class]]];
		}
		else*/
			[array addObject:[object yamlData]];
	}
	
	return array;
}

- (NSArray*)yamlParse
{
	return [self collectWithSelector:@selector(yamlParse)];
}

-(NSString*) yamlDescriptionWithIndent:(int)indent
{
	NSEnumerator		*enumerator = [self objectEnumerator];
	id					anObject, last = [self lastObject];
	NSMutableString		*description = [NSMutableString stringWithString:@"\n"];
	char				*strIndent = malloc(indent+1);
	
	if([self count] == 0)
		return @"[]";
	
	memset(strIndent, ' ', indent);
	strIndent[indent] = 0;
			
	while (anObject = [enumerator nextObject])
	{
		NSString	*tag;
		
		if(yamlClass(anObject))
			tag = @"";
		else 
			tag = [NSString stringWithFormat:@"!!%@ ", NSStringFromClass([anObject class])];
		
		anObject = [anObject toYAML];
		
		[description appendFormat:@"%s- %@%@%s", strIndent, tag,
			[anObject yamlDescriptionWithIndent:indent+2], anObject == last? "" : "\n"];
	}
	
	free(strIndent);
	
	return description;
}

- (id)toYAML
{
	return self;
}

- (id)firstObject
{
	if([self count])
		return [self objectAtIndex:0];
	return NULL;
}

- (NSArray*)collectWithSelector:(SEL)aSelector withObject:(id)anObject
{
	NSMutableArray  *array = [NSMutableArray array];
	unsigned i, c = [self count];
	
    for (i=0; i<c; i++)
	{
        [array addObject:
			[[self objectAtIndex:i] performSelector:aSelector withObject:anObject]];
    }
    return array;
}

- (NSArray*)collectWithSelector:(SEL)aSelector
{
	NSMutableArray  *array = [NSMutableArray array];
	unsigned i, c = [self count];
	
    for (i=0; i<c; i++)
	{
        [array addObject:
			[[self objectAtIndex:i] performSelector:aSelector]];
    }
    return array;
}

@end

@implementation NSDictionary (YAMLAdditions)

-(NSDictionary*) yamlData
{
	NSEnumerator		*enumerator;
	NSArray				*allKeys = [self allKeys];
	NSString			*key;
	
	NSMutableDictionary	*dict = [NSMutableDictionary dictionary];
	
	//output
	enumerator = [allKeys objectEnumerator];
	while (key = [enumerator nextObject])
	{
		id object = [self objectForKey:key];

		/*if(!yamlClass(object))
		{
			[dict setObject:[YAMLWrapper wrapperWithData:[object yamlData] tag:[object class]] forKey:key];
		}
		else*/
			[dict setObject:[object yamlData] forKey:key];
	}
	
	return dict;
}

- (NSDictionary*)yamlParse
{
	return [self collectWithSelector:@selector(yamlParse)];
}

-(NSString*) yamlDescriptionWithIndent:(int)indent
{
	NSEnumerator		*enumerator;
	NSArray				*allKeys = [self allKeys];
	NSString			*key, *last;
	
	NSMutableString		*description = [NSMutableString stringWithString:@"\n"];
	char				*strIndent = malloc(indent+1);
	int					keyLength = 0;
	
	if([self count] == 0)
		return @"{}";
	
	memset(strIndent, ' ', indent);
	strIndent[indent] = 0;
	
	//get longest key length
	allKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	last = [allKeys lastObject];
	enumerator = [allKeys objectEnumerator];
	while (key = [enumerator nextObject])
	{
		if([key length] > keyLength)
			keyLength = [key length];
	}
	
	//output
	enumerator = [allKeys objectEnumerator];
	while (key = [enumerator nextObject])
	{
		id object = [self objectForKey:key];
		NSString	*tag;
		
		if(yamlClass(object))
			tag = @"";
		else 
			tag = [NSString stringWithFormat:@"!!%@ ", NSStringFromClass([object class])];
		
		object = [object toYAML];
	
		[description appendFormat:@"%s%@: %@%@%s", strIndent, 
			[key stringByPaddingToLength:keyLength withString:@" " startingAtIndex:0],
			tag,
			[object yamlDescriptionWithIndent:indent+2], key == last? "" : "\n"];
	}
	
	free(strIndent);
	
	return description;
}

- (id)toYAML
{
	return self;
}

- (NSDictionary*)collectWithSelector:(SEL)aSelector withObject:(id)anObject
{
	NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
	NSArray *allKeys = [self allKeys];
	unsigned i, c = [allKeys count];
	
    for (i=0; i<c; i++)
	{
		id key = [allKeys objectAtIndex:i];
        [dict setObject: [[self objectForKey:key] performSelector:aSelector withObject:anObject]
			  forKey: key];
    }
    return dict;
}

- (NSDictionary*)collectWithSelector:(SEL)aSelector
{
	NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
	NSArray *allKeys = [self allKeys];
	unsigned i, c = [allKeys count];
	
    for (i=0; i<c; i++)
	{
		id key = [allKeys objectAtIndex:i];
        [dict setObject: [[self objectForKey:key] performSelector:aSelector]
			  forKey: key];
    }
    return dict;
}

@end

@implementation NSObject (YAMLAdditions)

-(NSString*) yamlDescriptionWithIndent:(int)indent
{
	return [self toYAML];
}

- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array {
    unsigned i, c = [array count];
    for (i=0; i<c; i++) {
        [self performSelector:sel withObject:[array objectAtIndex:i]];
    }
}

- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set {
    [self performSelector:sel withEachObjectInArray:[set allObjects]];
}

-(id) toYAML
{
    return nil;
}

-(NSString*) yamlDescription
{
    return [self toYAML];
}

@end

@implementation NSObject (PublicYAMLAdditions)

-(NSString*) yamlDescription
{
	return [self yamlDescriptionWithIndent:0];
}

- (id)yamlParse
{
	return self;
}

-(id) yamlData
{
	if(!yamlClass(self))
		 return [YAMLWrapper wrapperWithData:[self toYAML] tag:[self class]];
	else
		return [self toYAML];
}

-(id) toYAML
{
	return [self description];
}

@end