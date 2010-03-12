//
//  RootViewController.m
//  Client
//
//  Created by Adrian on 2/8/10.
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

#import <AddressBookUI/AddressBookUI.h>
#import "RootViewController.h"
#import "BaseDataLoader.h"
#import "BaseDeserializer.h"
#import "BenchmarkController.h"
#import "NSDictionary+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "SettingsController.h"

@interface RootViewController ()

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *sliderLabel;
@property (nonatomic, retain) UISegmentedControl *formatControl;
@property (nonatomic, retain) UIActivityIndicatorView *spinningWheel;

@property (nonatomic) DeserializerType currentDataFormat;
@property (nonatomic, retain) BaseDataLoader *dataLoader;
@property (nonatomic, retain) NSArray *data;
- (void)updateTitle;
@end


@implementation RootViewController

@synthesize dataLoader = _dataLoader;
@synthesize data = _data;
@synthesize currentDataFormat = _currentDataFormat;
@synthesize spinningWheel = _spinningWheel;
@synthesize formatControl = _formatControl;
@synthesize sliderLabel = _sliderLabel;
@synthesize slider = _slider;
@synthesize headerView = _headerView;

- (void)dealloc
{
    self.data = nil;
    self.dataLoader = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)sliderChanged:(id)sender
{
    NSInteger limit = (NSInteger)_slider.value;
    [NSUserDefaults standardUserDefaults].sliderValue = limit;
    self.sliderLabel.text = [NSString stringWithFormat:@"%d", limit];
}

- (IBAction)formatChanged:(id)sender
{
    switch (self.formatControl.selectedSegmentIndex) 
    {
        case 0:
            self.currentDataFormat = DeserializerTypeSBJSON;
            break;
            
        case 1:
            self.currentDataFormat = DeserializerTypeNSXMLParser;
            break;
            
        case 2:
            self.currentDataFormat = DeserializerTypeSOAP;
            break;
            
        case 3:
            self.currentDataFormat = DeserializerTypeBinaryPlist;
            break;
            
        case 4:
            self.currentDataFormat = DeserializerTypeYAML;
            break;
            
        case 5:
            self.currentDataFormat = DeserializerTypeCSV;
            break;

        case 6:
            self.currentDataFormat = DeserializerTypeProtocolBuffer;
            break;

        default:
            break;
    }
}

- (IBAction)refresh:(id)sender
{
    self.data = nil;
    [self.tableView reloadData];
    [self.spinningWheel startAnimating];

    if (self.currentDataFormat == DeserializerTypeSOAP)
    {
        self.dataLoader = [BaseDataLoader loaderWithMechanism:LoaderMechanismSOAP];
    }
    else
    {
        self.dataLoader = [BaseDataLoader loaderWithMechanism:LoaderMechanismASIHTTPRequest];
    }
    self.dataLoader.delegate = self;
    self.dataLoader.deserializer = [BaseDeserializer deserializerForFormat:self.currentDataFormat];
    self.dataLoader.limit = (NSInteger)_slider.value;
    [self.dataLoader loadData];

    [self updateTitle];
}

- (IBAction)showBenchmark:(id)sender
{
    BenchmarkController *benchmark = [[BenchmarkController alloc] init];
    [self.navigationController presentModalViewController:benchmark.navigationController 
                                                 animated:YES];
    [benchmark release];
}

- (IBAction)showSettings:(id)sender
{
    SettingsController *settings = [[SettingsController alloc] init];
    [self.navigationController presentModalViewController:settings.navigationController 
                                                 animated:YES];
    [settings release];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.headerView;
    NSInteger limit = [NSUserDefaults standardUserDefaults].sliderValue;
    self.slider.value = limit;
    self.sliderLabel.text = [NSString stringWithFormat:@"%d", limit];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_spinningWheel];
    self.navigationItem.rightBarButtonItem = item;
    [item release];

    self.currentDataFormat = DeserializerTypeTouchJSON;
    [self refresh:nil];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark DataLoaderDelegate methods

- (void)dataLoader:(BaseDataLoader *)loader didLoadData:(NSArray *)data
{
    [self.spinningWheel stopAnimating];
    self.data = data;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"ControllerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *dict = [self.data objectAtIndex:indexPath.row];
    NSString *firstName = [dict objectForKey:@"firstName"];
    NSString *lastName = [dict objectForKey:@"lastName"];
    NSString *email = [dict objectForKey:@"email"];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    cell.detailTextLabel.text = email;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.data objectAtIndex:indexPath.row];
    ABPersonViewController *personController = [[ABPersonViewController alloc] init];
    ABRecordRef person = dict.person;
    personController.displayedPerson = person;
    [self.navigationController pushViewController:personController animated:YES];
    [personController release];
    
}

#pragma mark -
#pragma mark Private methods

- (void)updateTitle
{
    NSInteger limit = (NSInteger)self.slider.value;
    self.title = [NSString stringWithFormat:@"%d + %@", limit, [self.dataLoader.deserializer formatIdentifier]];
}

@end
