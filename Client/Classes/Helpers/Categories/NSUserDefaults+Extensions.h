//
//  NSUserDefaults+Extensions.h
//  Client
//
//  Created by Adrian on 3/11/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Extensions)

- (void)setDefaultValuesIfRequired;

@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic) NSInteger benchmarkMaximum;
@property (nonatomic) NSInteger benchmarkIncrement;
@property (nonatomic) NSInteger sliderValue;

@end
