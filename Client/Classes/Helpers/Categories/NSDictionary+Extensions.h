//
//  NSDictionary+Extensions.h
//  Client
//
//  Created by Adrian on 3/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface NSDictionary (Extensions)

@property (nonatomic, readonly) ABRecordRef person;

@end
