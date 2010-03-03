/*NSDate+ISO8601Unparsing.m
 *
 *Created by Peter Hosey on 2006-05-29.
 *Copyright 2006 Peter Hosey. All rights reserved.
 *Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 *Modifications copyright 2009 Micropraxis Ltd.
 */

#import <Foundation/Foundation.h>

#ifndef DEFAULT_TIME_SEPARATOR
#	define DEFAULT_TIME_SEPARATOR ':'
#endif
unichar ISO8601UnparserDefaultTimeSeparatorCharacter = DEFAULT_TIME_SEPARATOR;

static BOOL is_leap_year(unsigned year) {
  return \
  ((year %   4U) == 0U)
  && (((year % 100U) != 0U)
      ||  ((year % 400U) == 0U));
}

@interface NSString(ISO8601Unparsing)

//Replace all occurrences of ':' with timeSep.
- (NSString *)prepareDateFormatWithTimeSeparator:(unichar)timeSep;

@end

@implementation NSDate(ISO8601Unparsing)

#pragma mark Public methods

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
  NSString *dateFormat = [(includeTime ? @"yyyy-MM-dd'T'HH:mm:ss" : @"yyyy-MM-dd") prepareDateFormatWithTimeSeparator:timeSep];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat: dateFormat];
  
  NSString *str = [formatter stringForObjectValue:self];
  [formatter release];
  if(includeTime) {
    // NSDate - all values are UTC
    str = [str stringByAppendingString: @"Z"];
  }
  return str;
}
/*Adapted from:
 *	Algorithm for Converting Gregorian Dates to ISO 8601 Week Date
 *	Rick McCarty, 1999
 *	http://personal.ecu.edu/mccartyr/ISOwdALG.txt
 */
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
  enum {
    monday, tuesday, wednesday, thursday, friday, saturday, sunday
  };
  enum {
    january = 1U, february, march,
    april, may, june,
    july, august, september,
    october, november, december
  };
  
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComps = [gregorian components: NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate: self];
  unsigned year = [dateComps year];
  unsigned week = 0U;
  unsigned dayOfWeek = ([dateComps weekday] + 6U) % 7U;
  unsigned dayOfYear = [gregorian ordinalityOfUnit: NSDayCalendarUnit inUnit: NSYearCalendarUnit forDate: self];
  
  unsigned prevYear = year - 1U;
  
  BOOL yearIsLeapYear = is_leap_year(year);
  BOOL prevYearIsLeapYear = is_leap_year(prevYear);
  
  unsigned YY = prevYear % 100U;
  unsigned C = prevYear - YY;
  unsigned G = YY + YY / 4U;
  unsigned Jan1Weekday = (((((C / 100U) % 4U) * 5U) + G) % 7U);
  
  unsigned weekday = ((dayOfYear + Jan1Weekday) - 1U) % 7U;
  
  [gregorian release];
  
  if((dayOfYear <= (7U - Jan1Weekday)) && (Jan1Weekday > thursday)) {
    week = 52U + ((Jan1Weekday == friday) || ((Jan1Weekday == saturday) && prevYearIsLeapYear));
    --year;
  } else {
    unsigned lengthOfYear = 365U + yearIsLeapYear;
    if((lengthOfYear - dayOfYear) < (thursday - weekday)) {
      ++year;
      week = 1U;
    } else {
      unsigned J = dayOfYear + (sunday - weekday) + Jan1Weekday;
      week = J / 7U - (Jan1Weekday > thursday);
    }
  }
  
  NSString *timeString;
  if(includeTime) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: [@"'T'HH:mm:ss'Z'" prepareDateFormatWithTimeSeparator: timeSep]];
    timeString = [formatter stringForObjectValue:self];
    [formatter release];
  } else
    timeString = @"";
  
  return [NSString stringWithFormat:@"%u-W%02u-%02u%@", year, week, dayOfWeek + 1U, timeString];
}
- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime timeSeparator:(unichar)timeSep {
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComps = [gregorian components: NSYearCalendarUnit fromDate: self];
  unsigned year = [dateComps year];
  unsigned dayOfYear = [gregorian ordinalityOfUnit: NSDayCalendarUnit inUnit: NSYearCalendarUnit forDate: self];
  NSString *timeString;

  [gregorian release];

  if(includeTime) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[@"'T'HH:mm:ss'Z'" prepareDateFormatWithTimeSeparator:timeSep]];
    timeString = [formatter stringForObjectValue:self];
    [formatter release];
  } else
    timeString = @"";
  
  return [NSString stringWithFormat:@"%u-%03u%@", year, dayOfYear, timeString];
}

#pragma mark -

- (NSString *)ISO8601DateStringWithTime:(BOOL)includeTime {
  return [self ISO8601DateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601WeekDateStringWithTime:(BOOL)includeTime {
  return [self ISO8601WeekDateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601OrdinalDateStringWithTime:(BOOL)includeTime {
  return [self ISO8601OrdinalDateStringWithTime:includeTime timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}

#pragma mark -

- (NSString *)ISO8601DateStringWithTimeSeparator:(unichar)timeSep {
  return [self ISO8601DateStringWithTime:YES timeSeparator:timeSep];
}
- (NSString *)ISO8601WeekDateStringWithTimeSeparator:(unichar)timeSep {
  return [self ISO8601WeekDateStringWithTime:YES timeSeparator:timeSep];
}
- (NSString *)ISO8601OrdinalDateStringWithTimeSeparator:(unichar)timeSep {
  return [self ISO8601OrdinalDateStringWithTime:YES timeSeparator:timeSep];
}

#pragma mark -

- (NSString *)ISO8601DateString {
  return [self ISO8601DateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601WeekDateString {
  return [self ISO8601WeekDateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}
- (NSString *)ISO8601OrdinalDateString {
  return [self ISO8601OrdinalDateStringWithTime:YES timeSeparator:ISO8601UnparserDefaultTimeSeparatorCharacter];
}

@end

@implementation NSString(ISO8601Unparsing)

//Replace all occurrences of ':' with timeSep.
- (NSString *)prepareDateFormatWithTimeSeparator:(unichar)timeSep {
  NSString *dateFormat = self;
  if(timeSep != ':') {
    NSMutableString *dateFormatMutable = [[dateFormat mutableCopy] autorelease];
    [dateFormatMutable replaceOccurrencesOfString:@":"
  withString:[NSString stringWithCharacters:&timeSep length:1U]
  options:NSBackwardsSearch | NSLiteralSearch
  range:(NSRange){ 0U, [dateFormat length] }];
    dateFormat = dateFormatMutable;
  }
  return dateFormat;
}

@end
