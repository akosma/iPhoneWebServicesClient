//
//  BenchmarkController.m
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

#import "BenchmarkController.h"
#import "BaseDataLoader.h"
#import "BaseDeserializer.h"
#import "Reachability.h"
#import "NSArray+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "UIDeviceHardware.h"

@interface BenchmarkController ()

@property (nonatomic, readonly) NSString *csvFilePath;
@property (nonatomic, readonly) NSString *connectionString;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSString *filename;

- (void)performNextBenchmark;

@end


@implementation BenchmarkController

@synthesize navigationController = _navigationController;
@synthesize tableView = _tableView;
@synthesize loaders = _loaders;
@synthesize testResults = _testResults;
@synthesize currentLimit = _currentLimit;
@synthesize currentLoaderIndex = _currentLoaderIndex;
@synthesize benchmarkFinished = _benchmarkFinished;
@synthesize running = _running;
@synthesize mailButton = _mailButton;
@synthesize startButton = _startButton;
@synthesize doneButton = _doneButton;
@synthesize benchmarkMaximum = _benchmarkMaximum;
@synthesize benchmarkIncrement = _benchmarkIncrement;
@synthesize benchmarkDate = _benchmarkDate;
@dynamic csvFilePath;
@dynamic connectionString;
@dynamic dateString;
@dynamic filename;

- (id)init
{
    self = [super initWithNibName:@"BenchmarkController" bundle:nil];
    if (self)
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        _navigationController.toolbarHidden = NO;
        _currentLimit = 0;
        _benchmarkFinished = NO;
        _running = NO;
        _currentLoaderIndex = 0;
        _benchmarkDate = [[NSDate alloc] init];
        _testResults = [[NSMutableArray alloc] initWithCapacity:100];
        _loaders = [[NSMutableArray alloc] initWithCapacity:21];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _benchmarkMaximum = defaults.benchmarkMaximum;
        _benchmarkIncrement = defaults.benchmarkIncrement;

        id<DataLoader> loader = nil;
        for (LoaderMechanism lm = 1; lm < LoaderMechanismSOAP; ++lm)
        {
            for (DeserializerType dt = 1; dt < DeserializerTypeSOAP; ++dt)
            {
                loader = [BaseDataLoader loaderWithMechanism:lm];
                loader.delegate = self;
                loader.deserializer = [BaseDeserializer deserializerForFormat:dt];
                [self.loaders addObject:loader];
            }
        }
        loader = [BaseDataLoader loaderWithMechanism:LoaderMechanismSOAP];
        loader.delegate = self;
        loader.deserializer = [BaseDeserializer deserializerForFormat:DeserializerTypeSOAP];
        [self.loaders addObject:loader];
    }
    return self;
}

- (void)dealloc
{
    [_doneButton release];
    _doneButton = nil;
    [_startButton release];
    _startButton = nil;
    [_mailButton release];
    _mailButton = nil;
    [_tableView release];
    _tableView = nil;
    [_testResults release];
    _testResults = nil;
    [_loaders release];
    _loaders = nil;
    [_navigationController release];
    _navigationController = nil;
    [_benchmarkDate release];
    _benchmarkDate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.startButton;
    self.navigationItem.leftBarButtonItem = self.doneButton;
    self.mailButton.enabled = [[NSFileManager defaultManager] fileExistsAtPath:self.csvFilePath];
    self.toolbarItems = [NSArray arrayWithObject:self.mailButton];
    self.title = @"Benchmark";
}

- (void)viewDidUnload
{
    self.doneButton = nil;
    self.startButton = nil;
    self.mailButton = nil;
    self.tableView = nil;
    self.navigationController = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)done:(id)sender
{
    self.running = NO;
    self.startButton.title = @"Start";
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)start:(id)sender
{
    if (self.running)
    {
        self.running = NO;
    }
    else 
    {
        self.benchmarkDate = [NSDate date];
        [self.testResults removeAllObjects];
        [self.tableView reloadData];
        self.currentLimit = 0;
        self.currentLoaderIndex = 0;
        self.benchmarkFinished = NO;
        self.running = YES;
        self.startButton.title = @"Stop";
        self.doneButton.enabled = NO;
        self.mailButton.enabled = NO;
        [self performNextBenchmark];
    }
}

- (IBAction)sendResultsViaEmail:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        
        NSString *baseURL = [NSUserDefaults standardUserDefaults].serverURL;
        NSString *connectionString = self.connectionString;
        NSString *device = [UIDeviceHardware platformString];
        NSString *template = @"<h3>Benchmark Results</h3>"
        @"<p>Test parameters:</p>"
        @"<ul>"
        @"<li>Date: <strong>%@</strong></li>"
        @"<li>URL: <strong>%@</strong></li>"
        @"<li>Device: <strong>%@</strong></li>"
        @"<li>Connection: <strong>%@</strong></li>"
        @"</ul>";
        NSString *body = [NSString stringWithFormat:template, baseURL, device, connectionString];
        [composer setMessageBody:body
                          isHTML:YES];
        
        [composer setSubject:@"iPhoneWebServicesClient Benchmark Results"];
        [composer addAttachmentData:[NSData dataWithContentsOfFile:self.csvFilePath]
                           mimeType:@"text/csv" 
                           fileName:self.filename];
        
        [self.navigationController presentModalViewController:composer 
                                                     animated:YES];
        [composer release];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)err
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark DataLoaderDelegate methods

- (void)dataLoader:(BaseDataLoader *)loader didLoadData:(NSArray *)data
{
    NSMutableDictionary *statistics = [NSMutableDictionary dictionaryWithCapacity:6];
    NSString *loaderClassName = [NSStringFromClass([loader class]) stringByReplacingOccurrencesOfString:@"DataLoader" 
                                                                                             withString:@""];
    NSString *deserializerClassName = [NSStringFromClass([loader.deserializer class]) stringByReplacingOccurrencesOfString:@"Deserializer"
                                                                                                                withString:@""];
    [statistics setObject:loaderClassName forKey:KEY_DATA_LOADER];
    [statistics setObject:deserializerClassName forKey:KEY_DESERIALIZER];
    [statistics setObject:[NSNumber numberWithInt:loader.limit] forKey:KEY_LIMIT];
    [statistics setObject:[NSNumber numberWithDouble:loader.interval] forKey:KEY_LOADER_TIME];
    [statistics setObject:[NSNumber numberWithDouble:loader.deserializer.interval] forKey:KEY_DESERIALIZER_TIME];
    [statistics setObject:[loader.deserializer formatIdentifier] forKey:KEY_FORMAT];
    
    NSUInteger size = [loader.data length];
    [statistics setObject:[NSNumber numberWithUnsignedInt:size] forKey:KEY_DATA_LENGTH];
    [self.testResults addObject:statistics];
    loader.data = nil;
    [self.tableView reloadData];
    [self performNextBenchmark];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    if (self.running)
    {
        headerTitle = [NSString stringWithFormat:@"Running... finished %d of %d tests", 
                       self.currentLoaderIndex, [self.loaders count]];
    }
    else if (self.benchmarkFinished)
    {
        headerTitle = @"Finished!";
    }
    else
    {
        headerTitle = @"Tap the 'Start' button to begin";
    }
    return headerTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.testResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = [self.testResults objectAtIndex:indexPath.row];
    NSString *dataLoaderClass = [item objectForKey:KEY_DATA_LOADER];
    NSString *deserializerClass = [item objectForKey:KEY_DESERIALIZER];
    NSInteger count = [[item objectForKey:KEY_LIMIT] intValue];
    NSTimeInterval loadInterval = [[item objectForKey:KEY_LOADER_TIME] doubleValue];
    NSTimeInterval deserializerInterval = [[item objectForKey:KEY_DESERIALIZER_TIME] doubleValue];
    float size = [[item objectForKey:KEY_DATA_LENGTH] unsignedIntValue] / 1024.0;

    cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@", dataLoaderClass, deserializerClass];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d items (%1.0f KB): %1.3f sec / %1.3f sec", 
                                 count, size, loadInterval, deserializerInterval];
    
    return cell;
}

#pragma mark -
#pragma mark Private methods

- (void)performNextBenchmark
{
    self.currentLimit += self.benchmarkIncrement;
    if (self.currentLimit > self.benchmarkMaximum)
    {
        self.currentLoaderIndex += 1;
        self.currentLimit = self.benchmarkIncrement;
    }
    
    if (self.running)
    {
        if (self.currentLoaderIndex < [self.loaders count])
        {
            id<DataLoader> loader = [self.loaders objectAtIndex:self.currentLoaderIndex];
            loader.limit = self.currentLimit;
            [loader loadData];
        }
        else
        {
            self.running = NO;
            self.startButton.title = @"Start";
            self.doneButton.enabled = YES;

            self.benchmarkFinished = YES;
            self.mailButton.enabled = YES;

            NSData *csv = [self.testResults formattedAsCSV];
            [csv writeToFile:self.csvFilePath atomically:YES];
        }
    }
    else
    {
        self.startButton.title = @"Start";
        self.doneButton.enabled = YES;
        self.mailButton.enabled = [[NSFileManager defaultManager] fileExistsAtPath:self.csvFilePath];
    }
}

- (NSString *)csvFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:self.filename];
}

- (NSString *)connectionString
{
    NSString *baseURL = [NSUserDefaults standardUserDefaults].serverURL;
    NSURL *url = [NSURL URLWithString:baseURL];
    Reachability *reachability = [Reachability reachabilityWithHostName:url.host];
    NSString *connectionString = nil;
    switch ([reachability currentReachabilityStatus]) 
    {
        case ReachableViaWiFi:
            connectionString = @"wifi";
            break;
            
        case NotReachable:
            connectionString = @"(none!)";
            break;
            
        case ReachableViaWWAN:
            connectionString = @"telephony";
            break;
            
        default:
            connectionString = @"(unknown)";
            break;
    }
    return connectionString;
}

- (NSString *)dateString
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyyMMdd_HHmm"];
    return [formatter stringFromDate:self.benchmarkDate];
}

- (NSString *)filename
{
    NSMutableString *fileName = [NSMutableString stringWithString:@"result_"];
    [fileName appendString:self.dateString];
    [fileName appendString:@"_"];
    [fileName appendString:[UIDeviceHardware platformString]];
    [fileName appendString:@"_"];
    [fileName appendString:self.connectionString];
    [fileName appendString:@".csv"];
    return fileName;
}

@end
