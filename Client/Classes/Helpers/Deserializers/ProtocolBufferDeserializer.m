//
//  ProtocolBufferDeserializer.m
//  Client
//
//  Created by Adrian on 3/11/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "ProtocolBufferDeserializer.h"
#import "Person.pb.h"

@implementation ProtocolBufferDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *keys = [NSArray arrayWithObjects:@"entryId", @"firstName", @"lastName", 
                     @"phone", @"email", @"address", @"city", @"zip", @"state", @"country", 
                     @"description", @"password", @"createdOn", @"modifiedOn", nil];
    Data *streamedData = [Data parseFromData:data];
    for (Person *person in [streamedData personList])
    {
        [array addObject:[person dictionaryWithValuesForKeys:keys]];
    }
    return array;
}

- (NSString *)formatIdentifier
{
    return @"pbuf";
}

@end
