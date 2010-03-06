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

#import "APAttribute.h"


@implementation APAttribute

@synthesize name;
@synthesize value;

/*
 Returns an APAttribute with the specified name and value.
*/
+ (id)attributeWithName:(NSString*)aName value:(NSString*)aValue {
	return [[[APAttribute alloc] initWithName:aName value:aValue] autorelease];
}

/*
 Initializes the receiver with a specified name and value
*/
- (id)initWithName:(NSString*)aName value:(NSString*)aValue {
	if (self = [super init])
	{
		name = [[NSString alloc] initWithString:aName];
		value = [[NSString alloc] initWithString:aValue];
	}
	
	return self;
}

- (void)dealloc {
	[name release];
	[value release];
	
    [super dealloc];
}

@end
