/*NSDate+ISO8601Unparsing.h
 *
 *Created by Peter Hosey on 2006-05-29.
 *Copyright 2006 Peter Hosey. All rights reserved.
 *Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 *Modifications copyright 2009 Micropraxis Ltd.
 */

#import <Foundation/Foundation.h>

/*This addition unparses dates to ISO 8601 strings. A good introduction to ISO 8601: <http://www.cl.cam.ac.uk/~mgk25/iso-time.html>
 */

//The default separator for time values. Currently, this is ':'.
extern unichar ISO8601UnparserDefaultTimeSeparatorCharacter;

@interface NSDate(ISO8601Unparsing)

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep;
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep;
- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep;

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime;
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime;
- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime;

//includeTime: YES.
- (NSString *)ISO8601DateStringWithTimeSeparator:(unichar)timeSep;
- (NSString *)ISO8601WeekDateStringWithTimeSeparator:(unichar)timeSep;
- (NSString *)ISO8601OrdinalDateStringWithTimeSeparator:(unichar)timeSep;

//includeTime: YES.
- (NSString *)ISO8601DateString;
- (NSString *)ISO8601WeekDateString;
- (NSString *)ISO8601OrdinalDateString;

@end

