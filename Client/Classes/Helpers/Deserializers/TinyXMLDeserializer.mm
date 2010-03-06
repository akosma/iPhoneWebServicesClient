//
//  TinyXMLDeserializer.mm
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TinyXMLDeserializer.h"
#import "tinyxml.h"

@implementation TinyXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    // Code adapted from 
    // http://www.raywenderlich.com/553/how-to-chose-the-best-xml-parser-for-your-iphone-project
    NSUInteger length = [data length];
    char *buffer = new char[length + 1];
    [data getBytes:buffer];
    buffer[length] = '\0';
    
    TiXmlDocument *doc = new TiXmlDocument();
    doc->Parse(buffer, 0, TIXML_ENCODING_UTF8);
    TiXmlHandle *handle = new TiXmlHandle(doc);

    TiXmlElement *person = handle->FirstChild("data").FirstChild("person").ToElement();
    NSMutableArray *array = [NSMutableArray array];

    while (person != NULL) 
    {
        TiXmlElement *attribute = person->FirstChild()->ToElement();
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        while (attribute != NULL)
        {
            NSString *value = [NSString stringWithUTF8String:attribute->GetText()];
            NSString *key = [NSString stringWithUTF8String:attribute->Value()];
            [dict setObject:value forKey:key];
            attribute = attribute->NextSiblingElement();
        }
        
        [array addObject:dict];
        [dict release];

        person = person->NextSiblingElement();
    }
    
    delete doc;
    delete handle;
    return array;
}

@end
