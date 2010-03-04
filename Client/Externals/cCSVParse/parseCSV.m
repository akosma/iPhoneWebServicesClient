/*
 * cCSVParse, a small CVS file parser
 *
 * © 2007-2009 Michael Stapelberg and contributors
 * http://michael.stapelberg.de/
 *
 * This source code is BSD-licensed, see LICENSE for the complete license.
 *
 */
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <stdbool.h>

#import "parseCSV.h"

/* Macros for determining if the given character is End Of Line or not */
#define EOL(x) ((*(x) == '\r' || *(x) == '\n') && *(x) != '\0')
#define NOT_EOL(x) (*(x) != '\0' && *(x) != '\r' && *(x) != '\n')

/*
 * replacement for strstr() which does only check every char instead
 * of complete strings
 * Warning: Do not call it with haystack == NULL || needle == NULL!
 *
 */
static char *cstrstr(const char *haystack, const char needle) {
	char *it = (char*)haystack;
	while (*it != '\0') {
		if (*it == needle)
			return it;
		it++;
	}
	return NULL;
}

@implementation CSVParser
/*
 * Copies a string without beginning- and end-quotes if there are
 * any and returns a pointer to the string or NULL if malloc() failed
 *
 */
-(NSString*)parseString:(char*)textp withLastStop:(char*)laststop {
	int stringSize = (int)(textp - laststop);
	if (*laststop == '\"' && *(laststop+1) != '\0' && *(laststop + stringSize - 1) == '\"') {
		laststop++;
		stringSize -= 2;
	}
	char *retval = (char*)malloc(stringSize + 1);
	if (retval == NULL)
		return NULL;
	strncpy(retval, laststop, (size_t)(stringSize));
	retval[stringSize] = '\0';
	NSMutableString *tempString = [NSMutableString stringWithCString: retval encoding:encoding];
	free(retval);
	retval = NULL;
	[tempString replaceOccurrencesOfString:@"\"\"" 
				    withString:@"\"" 
				       options:0
				         range:NSMakeRange(0, [tempString length])];
	return [NSString stringWithString: tempString];
}

-(id)init {
	self = [super init];
	if (self) {
		// Set default bufferSize
		bufferSize = 2048;
		// Set fileHandle to an invalid value
		fileHandle = 0;
		// Set delimiter to 0
		delimiter = '\0';
		// Set default encoding
		encoding = NSISOLatin1StringEncoding;
	}
	return self;
}

/*
 * Gets the CSV-delimiter from the given filename using the first line
 * which should be the header-line. Returns 0 on error.
 *
 */
-(char)autodetectDelimiter {
	char possibleDelimiters[4] = ",;\t\0";

	char buffer[bufferSize+1];
	// Seek to the beginning of the file
	lseek(fileHandle, 0, SEEK_SET);

	// Fill the buffer
	if (read(fileHandle, buffer, bufferSize) > 0) {
		char *textp = buffer;
		// ...we assume that this is the header which also contains the separation character
		while (NOT_EOL(textp) && cstrstr(possibleDelimiters, *textp) == NULL)
			textp++;

		// Check if a delimiter was found and set it
		if (NOT_EOL(textp)) {
			delimiter = *cstrstr((const char*)possibleDelimiters, *textp);
			return delimiter;
		}
	}

	return 0;
}

/*
 * Parses the CSV-file with the given filename and stores the result in a
 * NSMutableArray.
 *
 */
-(NSMutableArray*)parseFile {
	NSMutableArray *csvLine = [NSMutableArray array];
	NSMutableArray *csvContent = [NSMutableArray array];
	if (fileHandle <= 0)
		return csvContent;
	char possibleDelimiters[4] = ",;\t\0";
	int n = 1, diff;
	unsigned int quoteCount = 0;
	bool firstLine = true;
	char *buffer = malloc(sizeof(char) * (bufferSize + 1));
	char *textp, *laststop, *lineBeginning, *lastLineBuffer = NULL;
	lseek(fileHandle, 0, SEEK_SET);
	while (n > 0) {
		if (lastLineBuffer != NULL) {
			if (strlen(lastLineBuffer) == bufferSize) {
				[csvContent removeAllObjects];
				[csvContent addObject: [NSArray arrayWithObject: @"ERROR: Buffer too small"]];
				return csvContent;
			}

			// Care for the quotes in lastLineBuffer!
			textp = lastLineBuffer;
			while (*textp != '\0') {
				if (*textp == '\"')
					quoteCount++;
				textp++;
			}
			strcpy(buffer, lastLineBuffer);
			diff = strlen(lastLineBuffer);
			// Make the buffer bigger
			buffer = realloc(buffer, diff + bufferSize);
			if (buffer == NULL) {
				[csvContent removeAllObjects];
				[csvContent addObject: [NSArray arrayWithObject: @"ERROR: Could not allocate bytes for buffer"]];
				return csvContent;
			}
			lastLineBuffer = NULL;
		} else diff = 0;
		n = read(fileHandle, (buffer + diff), bufferSize);
		if (n <= 0)
			break;
		// Terminate buffer correctly
		if ((diff+n) <= (bufferSize + diff))
			buffer[diff+n] = '\0';
		
		textp = (char*)buffer;

		while (*textp != '\0') {
			// If we don't have a delimiter yet and this is the first line...
			if (firstLine && delimiter == '\0') {
				firstLine = false;
				// ...we assume that this is the header which also contains the separation character
				while (NOT_EOL(textp) && cstrstr(possibleDelimiters, *textp) == NULL)
					textp++;

				// Check if a delimiter was found and set it
				if (NOT_EOL(textp)) {
					delimiter = *cstrstr((const char*)possibleDelimiters, *textp);
					printf("delim is %c / %d :-)\n", delimiter, delimiter);
					while (NOT_EOL(textp))
						textp++;
				}

				textp = (char*)buffer;
			} 

			if (strlen(textp) > 0) {
				// This is data
				laststop = textp;
				lineBeginning = textp;

				// Parsing is splitted in parts till EOL
				while (NOT_EOL(textp) || (*textp != '\0' && (quoteCount % 2) != 0)) {
					// If we got two quotes and a delimiter before and after, this is an empty value
					if (	*textp == '\"' && 
						*(textp+1) == '\"') {
						// we'll just skip this, but firstly check if it's an empty value
						if (	(textp > (const char*)buffer) && 
							*(textp-1) == delimiter && 
							*(textp+2) == delimiter) {
							[csvLine addObject: @""];
						}
						textp++;
					} else if (*textp == '\"')
						quoteCount++;
					else if (*textp == delimiter && (quoteCount % 2) == 0) {
						// There is a delimiter which is not between an unmachted pair of quotes?
						[csvLine addObject: [self parseString:textp withLastStop:laststop]];
						laststop = textp + 1;
					}

					// Go to the next character
					textp++;
				}

				if (laststop == textp && *(textp-1) == delimiter) {
					[csvLine addObject:@""];
					if ((int)(buffer + bufferSize + diff - textp) > 0) {
						lineBeginning = textp + 1;
						[csvContent addObject: csvLine];
					}
					csvLine = [NSMutableArray new];
					[csvLine autorelease];
				}
				if (laststop != textp && (quoteCount % 2) == 0) {
					[csvLine addObject: [self parseString:textp withLastStop:laststop]];
					
					if ((int)(buffer + bufferSize + diff - textp) > 0) {
						lineBeginning = textp + 1;
						[csvContent addObject: csvLine];
					}
					csvLine = [NSMutableArray new];
					[csvLine autorelease];
				} 
				if ((*textp == '\0' || (quoteCount % 2) != 0) && lineBeginning != textp) {
					lastLineBuffer = lineBeginning;
					csvLine = [NSMutableArray new];
					[csvLine autorelease];
				}
			}

			while (EOL(textp))
				textp++;
		}
	}

	free(buffer);
	buffer = NULL;

	return csvContent;
}

-(BOOL)openFile:(NSString*)fileName {
	fileHandle = open([fileName UTF8String], O_RDONLY);
	return (fileHandle > 0);
}

-(void)closeFile {
	if (fileHandle > 0) {
		close(fileHandle);
		fileHandle = 0;
	}
}

-(char)delimiter {
	return delimiter;
}

-(void)setDelimiter:(char)newDelimiter {
	delimiter = newDelimiter;
}

-(void)setBufferSize:(int)newBufferSize {
	bufferSize = newBufferSize;
}
-(void)setEncoding:(NSStringEncoding)newEncoding {
	encoding = newEncoding;
}
@end
