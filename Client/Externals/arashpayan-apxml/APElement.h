/*
 Copyright 2009, Arash Payan (http://arashpayan.com)
 This library is distributed under the terms of the GNU Lesser GPL.
 
 This file is part of APXML.
 
 APXML is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 APXML is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with APXML.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
@class APAttribute;


@interface APElement : NSObject {
	NSString *name;
	NSMutableString *value;
	APElement *parent;
	
	NSMutableDictionary *attributes;
	NSMutableArray *childElements;
}

@property (readonly) NSString *name;
@property (nonatomic, assign) APElement *parent;

+ (id)elementWithName:(NSString*)aName;
+ (id)elementWithName:(NSString*)aName attributes:(NSDictionary*)someAttributes;
- (id)initWithName:(NSString*)aName;
- (void)addAttribute:(APAttribute*)anAttribute;
- (void)addAttributeNamed:(NSString*)aName withValue:(NSString*)aValue;
- (void)addAttributes:(NSDictionary*)someAttributes;
- (void)addChild:(APElement*)anElement;
- (void)appendValue:(NSString*)aValue;
- (int)attributeCount;
- (int)childCount;
- (NSArray*)childElements;
- (NSMutableArray*)childElements:(NSString*)aName;
- (APElement*)firstChildElement;
- (APElement*)firstChildElementNamed:(NSString*)aName;
- (NSString*)value;
- (NSString*)valueForAttributeNamed:(NSString*)aName;
- (NSString*)encodeEntities:(NSMutableString*)aString;
- (NSString*)prettyXML:(int)tabs;
- (NSString*)xml;

@end
