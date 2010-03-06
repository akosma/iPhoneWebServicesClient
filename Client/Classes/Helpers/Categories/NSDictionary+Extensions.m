//
//  NSDictionary+Extensions.m
//  Client
//
//  Created by Adrian on 3/3/10.
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
