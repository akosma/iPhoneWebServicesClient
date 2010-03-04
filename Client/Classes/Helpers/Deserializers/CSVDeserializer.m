//
//  CSVDeserializer.m
//  Client
//
//  Created by Adrian on 3/4/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "CSVDeserializer.h"
#import "parseCSV.h"

#define FILE_NAME @"csvdata.csv"

@interface CSVDeserializer ()
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@end


@implementation CSVDeserializer

@dynamic applicationDocumentsDirectory;

- (NSArray *)performDeserialization:(id)data
{
    NSString *fileName = [self.applicationDocumentsDirectory stringByAppendingPathComponent:FILE_NAME];
    [data writeToFile:fileName atomically:YES];
    
    CSVParser *parser = [CSVParser new];
    [parser openFile:fileName];
    NSArray *csvContents = [parser parseFile];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[csvContents count]];
    for (NSArray *item in csvContents) 
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[item count]];
        [dict setObject:[item objectAtIndex:0] forKey:@"entryId"];
        [dict setObject:[item objectAtIndex:1] forKey:@"firstName"];
        [dict setObject:[item objectAtIndex:2] forKey:@"lastName"];
        [dict setObject:[item objectAtIndex:3] forKey:@"phone"];
        [dict setObject:[item objectAtIndex:4] forKey:@"email"];
        [dict setObject:[item objectAtIndex:5] forKey:@"address"];
        [dict setObject:[item objectAtIndex:6] forKey:@"city"];
        [dict setObject:[item objectAtIndex:7] forKey:@"zip"];
        [dict setObject:[item objectAtIndex:8] forKey:@"state"];
        [dict setObject:[item objectAtIndex:9] forKey:@"country"];
        [dict setObject:[item objectAtIndex:10] forKey:@"description"];
        [dict setObject:[item objectAtIndex:11] forKey:@"password"];
        [dict setObject:[item objectAtIndex:12] forKey:@"createdOn"];
        [dict setObject:[item objectAtIndex:13] forKey:@"modifiedOn"];
        [result addObject:dict];
    }
    [parser closeFile];
    return result;
}

- (NSString *)formatIdentifier
{
    return @"csv";
}

#pragma mark -
#pragma mark Private methods

- (NSString *)applicationDocumentsDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
