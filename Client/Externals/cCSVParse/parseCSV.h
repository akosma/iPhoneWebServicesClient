/*
 * cCSVParse, a small CVS file parser
 *
 * © 2007-2009 Michael Stapelberg and contributors
 * http://michael.stapelberg.de/
 *
 * This source code is BSD-licensed, see LICENSE for the complete license.
 *
 */
#import <Cocoa/Cocoa.h>

@interface CSVParser:NSObject {
	int fileHandle;
	int bufferSize;
	char delimiter;
	NSStringEncoding encoding;
}
-(id)init;
-(BOOL)openFile:(NSString*)fileName;
-(void)closeFile;
-(char)autodetectDelimiter;
-(char)delimiter;
-(void)setDelimiter:(char)newDelimiter;
-(void)setBufferSize:(int)newBufferSize;
-(NSMutableArray*)parseFile;
-(void)setEncoding:(NSStringEncoding)newEncoding;
@end
