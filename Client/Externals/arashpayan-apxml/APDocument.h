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
@class APElement;


@interface APDocument : NSObject {
	APElement *rootElement;
}

+ (id)documentWithXMLString:(NSString*)anXMLString;
- (id)initWithRootElement:(APElement*)aRootElement;
- (id)initWithString:(NSString*)anXMLString;
- (APElement*)rootElement;
- (NSString*)prettyXML;
- (NSString*)xml;

@end
