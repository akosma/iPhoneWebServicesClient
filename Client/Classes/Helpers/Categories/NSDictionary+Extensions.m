//
//  NSDictionary+Extensions.m
//  Client
//
//  Created by Adrian on 3/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "NSDictionary+Extensions.h"

void setPersonPropertyValue(ABRecordRef person, ABPropertyID property, CFStringRef label, NSString *value)
{
    if (value != nil && ![value isEqualToString:@""])
    {
        ABMutableMultiValueRef items = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        CFIndex index = ABMultiValueGetCount(items);
        ABMultiValueInsertValueAndLabelAtIndex(items, (CFStringRef)value, label, index, nil);
        ABRecordSetValue(person, property, items, nil);
        CFRelease(items);
    }
}

@implementation NSDictionary(Extensions)

@dynamic person;

- (ABRecordRef)person
{
    NSString *firstName = [self objectForKey:@"firstName"];
    NSString *lastName = [self objectForKey:@"lastName"];
    NSString *phone = [self objectForKey:@"phone"];
    NSString *email = [self objectForKey:@"email"];
    NSString *description = [self objectForKey:@"description"];

    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, firstName, nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, lastName, nil);
    ABRecordSetValue(person, kABPersonNoteProperty, description, nil);

    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    
    // Set up keys and values for the dictionary.
    CFStringRef keys[5];
    CFStringRef values[5];
    keys[0]      = kABPersonAddressStreetKey;
    keys[1]      = kABPersonAddressCityKey;
    keys[2]      = kABPersonAddressStateKey;
    keys[3]      = kABPersonAddressZIPKey;
    keys[4]      = kABPersonAddressCountryKey;
    values[0]    = (CFStringRef)[self objectForKey:@"address"];
    values[1]    = (CFStringRef)[self objectForKey:@"city"];
    values[2]    = (CFStringRef)[self objectForKey:@"state"];
    values[3]    = (CFStringRef)[[self objectForKey:@"zip"] description];
    values[4]    = (CFStringRef)[self objectForKey:@"country"];
    
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               5,
                                               &kCFCopyStringDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks
                                               );
    
    // Add the street address to the person record.
    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(address, aDict, kABHomeLabel, &identifier);
    CFRelease(aDict);
    ABRecordSetValue(person, kABPersonAddressProperty, address, nil);
    CFRelease(address);
    
    setPersonPropertyValue(person, kABPersonPhoneProperty, kABPersonPhoneMobileLabel, phone);
    setPersonPropertyValue(person, kABPersonEmailProperty, kABWorkLabel, email);
    setPersonPropertyValue(person, kABPersonEmailProperty, kABWorkLabel, email);
    
    return person;
}

@end
