/*NSDate+ISO8601Parsing.m
 *
 *Created by Peter Hosey on 2006-02-20.
 *Copyright 2006 Peter Hosey. All rights reserved.
 *Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 *Modifications copyright 2009 Micropraxis Ltd.
 */

#include <ctype.h>
#include <string.h>

#import "NSDate+ISO8601Parsing.h"

#ifndef DEFAULT_TIME_SEPARATOR
#	define DEFAULT_TIME_SEPARATOR ':'
#endif
unichar ISO8601ParserDefaultTimeSeparatorCharacter = DEFAULT_TIME_SEPARATOR;

static unsigned read_segment(const unsigned char *str, const unsigned char **next, unsigned *out_num_digits) {
  unsigned num_digits = 0U;
  unsigned value = 0U;
  
  while(isdigit(*str)) {
    value *= 10U;
    value += *str - '0';
    ++num_digits;
    ++str;
  }
  
  if(next) *next = str;
  if(out_num_digits) *out_num_digits = num_digits;
  
  return value;
}
static unsigned read_segment_4digits(const unsigned char *str, const unsigned char **next, unsigned *out_num_digits) {
  unsigned num_digits = 0U;
  unsigned value = 0U;
  
  if(isdigit(*str)) {
    value += *(str++) - '0';
    ++num_digits;
  }
  
  if(isdigit(*str)) {
    value *= 10U;
    value += *(str++) - '0';
    ++num_digits;
  }
  
  if(isdigit(*str)) {
    value *= 10U;
    value += *(str++) - '0';
    ++num_digits;
  }
  
  if(isdigit(*str)) {
    value *= 10U;
    value += *(str++) - '0';
    ++num_digits;
  }
  
  if(next) *next = str;
  if(out_num_digits) *out_num_digits = num_digits;
  
  return value;
}
static unsigned read_segment_2digits(const unsigned char *str, const unsigned char **next) {
  unsigned value = 0U;
  
  if(isdigit(*str))
    value += *str - '0';
  
  if(isdigit(*++str)) {
    value *= 10U;
    value += *(str++) - '0';
  }
  
  if(next) *next = str;
  
  return value;
}

//strtod doesn't support ',' as a separator. This does.
static double read_double(const unsigned char *str, const unsigned char **next) {
  double value = 0.0;
  
  if(str) {
    unsigned int_value = 0;
    
    while(isdigit(*str)) {
      int_value *= 10U;
      int_value += (*(str++) - '0');
    }
    value = int_value;
    
    if(((*str == ',') || (*str == '.'))) {
      ++str;
      
      register double multiplier, multiplier_multiplier;
      multiplier = multiplier_multiplier = 0.1;
      
      while(isdigit(*str)) {
        value += (*(str++) - '0') * multiplier;
        multiplier *= multiplier_multiplier;
      }
    }
  }
  
  if(next) *next = str;
  
  return value;
}

static BOOL is_leap_year(unsigned year) {
  return \
  ((year %   4U) == 0U)
  && (((year % 100U) != 0U)
      ||  ((year % 400U) == 0U));
}

@implementation NSDate(ISO8601Parsing)

/*Valid ISO 8601 date formats:
 *
 *YYYYMMDD
 *YYYY-MM-DD
 *YYYY-MM
 *YYYY
 *YY //century 
 * //Implied century: YY is 00-99
 *  YYMMDD
 *  YY-MM-DD
 * -YYMM
 * -YY-MM
 * -YY
 * //Implied year
 *  --MMDD
 *  --MM-DD
 *  --MM
 * //Implied year and month
 *   ---DD
 * //Ordinal dates: DDD is the number of the day in the year (1-366)
 *YYYYDDD
 *YYYY-DDD
 *  YYDDD
 *  YY-DDD
 *   -DDD
 * //Week-based dates: ww is the number of the week, and d is the number (1-7) of the day in the week
 *yyyyWwwd
 *yyyy-Www-d
 *yyyyWww
 *yyyy-Www
 *yyWwwd
 *yy-Www-d
 *yyWww
 *yy-Www
 * //Year of the implied decade
 *-yWwwd
 *-y-Www-d
 *-yWww
 *-y-Www
 * //Week and day of implied year
 *  -Wwwd
 *  -Www-d
 * //Week only of implied year
 *  -Www
 * //Day only of implied week
 *  -W-d
 */
+ (NSDate *)dateWithString:(NSString *)str strictly:(BOOL)strict timeSeparator:(unichar)timeSep getRange:(out NSRange *)outRange {
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSGregorianCalendar];
  NSDate *now = [NSDate date];
  NSDateComponents *dateComps = [gregorian components: NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate: now];
  unsigned
  //Date
  year,
  month_or_week = 1U,
  day = 1U,
  //Time
  hour = 0U;
  NSTimeInterval
  minute = 0.0,
  second = 0.0;
  //Time zone
  signed tz_hour = 0;
  signed tz_minute = 0;
  
  enum {
    monthAndDate,
    week,
    dateOnly
  } dateSpecification = monthAndDate;
  
  if(strict) timeSep = ISO8601ParserDefaultTimeSeparatorCharacter;
  NSAssert(timeSep != '\0', @"Time separator must not be NUL.");
  
  BOOL isValidDate = ([str length] > 0U);
  NSTimeZone *timeZone = nil;
  NSDate *date = nil;
  
  const unsigned char *ch = (const unsigned char *)[str UTF8String];
  
  NSRange range = { 0U, 0U };
  const unsigned char *start_of_date;
  if(strict && isspace(*ch)) {
    range.location = NSNotFound;
    isValidDate = NO;
  } else {
    //Skip leading whitespace.
    unsigned i = 0U;
    unsigned len = strlen((const char *)ch);
    for(; i < len; ++i) {
      if(!isspace(ch[i]))
        break;
    }
    
    range.location = i;
    ch += i;
    start_of_date = ch;
    
    unsigned segment;
    unsigned num_leading_hyphens = 0U, num_digits = 0U;
        
    if(*ch == 'T') {
      //There is no date here, only a time. Set the date to now; then we'll parse the time.
      isValidDate = isdigit(*++ch);
      
      year = [dateComps year];
      month_or_week = [dateComps month];
      day = [dateComps day];
    } else {
      while(*ch == '-') {
        ++num_leading_hyphens;
        ++ch;
      }
      
      segment = read_segment(ch, &ch, &num_digits);
      switch(num_digits) {
        case 0:
          if(*ch == 'W') {
            if((ch[1] == '-') && isdigit(ch[2]) && ((num_leading_hyphens == 1U) || ((num_leading_hyphens == 2U) && !strict))) {
              year = [dateComps year];
              month_or_week = 1U;
              ch += 2;
              goto parseDayAfterWeek;
            } else if(num_leading_hyphens == 1U) {
              year = [dateComps year];
              goto parseWeekAndDay;
            } else
              isValidDate = NO;
          } else
            isValidDate = NO;
          break;
          
        case 8: //YYYY MM DD
          if(num_leading_hyphens > 0U)
            isValidDate = NO;
          else {
            day = segment % 100U;
            segment /= 100U;
            month_or_week = segment % 100U;
            year = segment / 100U;
          }
          break;
          
        case 6: //YYMMDD (implicit century)
          if(num_leading_hyphens > 0U)
            isValidDate = NO;
          else {
            day = segment % 100U;
            segment /= 100U;
            month_or_week = segment % 100U;
            year  = [dateComps year];
            year -= (year % 100U);
            year += segment / 100U;
          }
          break;
          
        case 4:
          switch(num_leading_hyphens) {
            case 0: //YYYY
              year = segment;
              
              if(*ch == '-') ++ch;
              
              if(!isdigit(*ch)) {
                if(*ch == 'W')
                  goto parseWeekAndDay;
                else
                  month_or_week = day = 1U;
              } else {
                segment = read_segment(ch, &ch, &num_digits);
                switch(num_digits) {
                  case 4: //MMDD
                    day = segment % 100U;
                    month_or_week = segment / 100U;
                    break;
                    
                  case 2: //MM
                    month_or_week = segment;
                    
                    if(*ch == '-') ++ch;
                    if(!isdigit(*ch))
                      day = 1U;
                    else
                      day = read_segment(ch, &ch, NULL);
                    break;
                    
                  case 3: //DDD
                    day = segment % 1000U;
                    dateSpecification = dateOnly;
                    if(strict && (day > (365U + is_leap_year(year))))
                      isValidDate = NO;
                    break;
                    
                  default:
                    isValidDate = NO;
                }
              }
              break;
              
            case 1: //YYMM
              month_or_week = segment % 100U;
              year = segment / 100U;
              
              if(*ch == '-') ++ch;
              if(!isdigit(*ch))
                day = 1U;
              else
                day = read_segment(ch, &ch, NULL);
              
              break;
              
            case 2: //MMDD
              day = segment % 100U;
              month_or_week = segment / 100U;
              year = [dateComps year];
              
              break;
              
            default:
              isValidDate = NO;
          } //switch(num_leading_hyphens) (4 digits)
          break;
          
        case 1:
          if(strict) {
            //Two digits only - never just one.
            if(num_leading_hyphens == 1U) {
              if(*ch == '-') ++ch;
              if(*++ch == 'W') {
                year  = [dateComps year];
                year -= (year % 10U);
                year += segment;
                goto parseWeekAndDay;
              } else
                isValidDate = NO;
            } else
              isValidDate = NO;
            break;
          }
        case 2:
          switch(num_leading_hyphens) {
            case 0:
              if(*ch == '-') {
                //Implicit century
                year  = [dateComps year];
                year -= (year % 100U);
                year += segment;
                
                if(*++ch == 'W')
                  goto parseWeekAndDay;
                else if(!isdigit(*ch)) {
                  goto centuryOnly;
                } else {
                  //Get month and/or date.
                  segment = read_segment_4digits(ch, &ch, &num_digits);
                  NSLog(@"(%@) parsing month; segment is %u and ch is %s", str, segment, ch);
                  switch(num_digits) {
                    case 4: //YY-MMDD
                      day = segment % 100U;
                      month_or_week = segment / 100U;
                      break;
                      
                    case 1: //YY-M; YY-M-DD (extension)
                      if(strict) {
                        isValidDate = NO;
                        break;
                      }
                    case 2: //YY-MM; YY-MM-DD
                      month_or_week = segment;
                      if(*ch == '-') {
                        if(isdigit(*++ch))
                          day = read_segment_2digits(ch, &ch);
                        else
                          day = 1U;
                      } else
                        day = 1U;
                      break;
                      
                    case 3: //Ordinal date.
                      day = segment;
                      dateSpecification = dateOnly;
                      break;
                  }
                }
              } else if(*ch == 'W') {
                year  = [dateComps year];
                year -= (year % 100U);
                year += segment;
                
              parseWeekAndDay: //*ch should be 'W' here.
                if(!isdigit(*++ch)) {
                  //Not really a week-based date; just a year followed by '-W'.
                  if(strict)
                    isValidDate = NO;
                  else
                    month_or_week = day = 1U;
                } else {
                  month_or_week = read_segment_2digits(ch, &ch);
                  if(*ch == '-') ++ch;
                parseDayAfterWeek:
                  day = isdigit(*ch) ? read_segment_2digits(ch, &ch) : 1U;
                  dateSpecification = week;
                }
              } else {
                //Century only. Assume current year.
              centuryOnly:
                year = segment * 100U + [dateComps year] % 100U;
                month_or_week = day = 1U;
              }
              break;
              
            case 1:; //-YY; -YY-MM (implicit century)
              NSLog(@"(%@) found %u digits and one hyphen, so this is either -YY or -YY-MM; segment (year) is %u", str, num_digits, segment);
              unsigned current_year = [dateComps year];
              unsigned century = (current_year % 100U);
              year = segment + (current_year - century);
              if(num_digits == 1U) //implied decade
                year += century - (current_year % 10U);
              
              if(*ch == '-') {
                ++ch;
                month_or_week = read_segment_2digits(ch, &ch);
                NSLog(@"(%@) month is %u", str, month_or_week);
              } else {
                month_or_week = 1U;
              }
              
              day = 1U;
              break;
              
            case 2: //--MM; --MM-DD
              year = [dateComps year];
              month_or_week = segment;
              if(*ch == '-') {
                ++ch;
                day = read_segment_2digits(ch, &ch);
              } else {
                day = 1U;
              }
              break;
              
            case 3: //---DD
              year = [dateComps year];
              month_or_week = [dateComps month];
              day = segment;
              break;
              
            default:
              isValidDate = NO;
          } //switch(num_leading_hyphens) (2 digits)
          break;
          
        case 7: //YYYY DDD (ordinal date)
          if(num_leading_hyphens > 0U)
            isValidDate = NO;
          else {
            day = segment % 1000U;
            year = segment / 1000U;
            dateSpecification = dateOnly;
            if(strict && (day > (365U + is_leap_year(year))))
              isValidDate = NO;
          }
          break;
          
        case 3: //--DDD (ordinal date, implicit year)
          //Technically, the standard only allows one hyphen. But it says that two hyphens is the logical implementation, and one was dropped for brevity. So I have chosen to allow the missing hyphen.
          if((num_leading_hyphens < 1U) || ((num_leading_hyphens > 2U) && !strict))
            isValidDate = NO;
          else {
            day = segment;
            year = [dateComps year];
            dateSpecification = dateOnly;
            if(strict && (day > (365U + is_leap_year(year))))
              isValidDate = NO;
          }
          break;
          
        default:
          isValidDate = NO;
      }
    }
    
    if(isValidDate) {
      if(isspace(*ch) || (*ch == 'T')) ++ch;
      
      if(isdigit(*ch)) {
        hour = read_segment_2digits(ch, &ch);
        if(*ch == timeSep) {
          ++ch;
          if((timeSep == ',') || (timeSep == '.')) {
            //We can't do fractional minutes when '.' is the segment separator.
            //Only allow whole minutes and whole seconds.
            minute = read_segment_2digits(ch, &ch);
            if(*ch == timeSep) {
              ++ch;
              second = read_segment_2digits(ch, &ch);
            }
          } else {
            //Allow a fractional minute.
            //If we don't get a fraction, look for a seconds segment.
            //Otherwise, the fraction of a minute is the seconds.
            minute = read_double(ch, &ch);
            second = modf(minute, &minute);
            if(second > DBL_EPSILON)
              second *= 60.0; //Convert fraction (e.g. .5) into seconds (e.g. 30).
            else if(*ch == timeSep) {
              ++ch;
              second = read_double(ch, &ch);
            }
          }
        }
        
        switch(*ch) {
          case 'Z':
            timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            break;
            
          case '+':
          case '-':;
            BOOL negative = (*ch == '-');
            if(isdigit(*++ch)) {
              //Read hour offset.
              segment = *ch - '0';
              if(isdigit(*++ch)) {
                segment *= 10U;
                segment += *(ch++) - '0';
              }
              tz_hour = (signed)segment;
              if(negative) tz_hour = -tz_hour;
              
              //Optional separator.
              if(*ch == timeSep) ++ch;
              
              if(isdigit(*ch)) {
                //Read minute offset.
                segment = *ch - '0';
                if(isdigit(*++ch)) {
                  segment *= 10U;
                  segment += *ch - '0';
                }
                tz_minute = segment;
                if(negative) tz_minute = -tz_minute;
              }
              
              timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(tz_hour * 3600) + (tz_minute * 60)];
            }
        }
      }
    }
    
    if(isValidDate) {
      if (timeZone != nil)
        [gregorian setTimeZone: timeZone];
      
      switch(dateSpecification) {
        case monthAndDate:
          [dateComps setYear: year];
          [dateComps setMonth: month_or_week];
          [dateComps setDay: day];
          [dateComps setHour: hour];
          [dateComps setMinute: minute];
          [dateComps setSecond: second];
          date = [gregorian dateFromComponents: dateComps];
          break;
          
        case week:;
          //Adapted from <http://personal.ecu.edu/mccartyr/ISOwdALG.txt>.
          //This works by converting the week date into an ordinal date, then letting the next case handle it.
          unsigned prevYear = year - 1U;
          unsigned YY = prevYear % 100U;
          unsigned C = prevYear - YY;
          unsigned G = YY + YY / 4U;
          unsigned isLeapYear = (((C / 100U) % 4U) * 5U);
          unsigned Jan1Weekday = (isLeapYear + G) % 7U;
          enum { monday, tuesday, wednesday, thursday/*, friday, saturday, sunday*/ };
          day = ((8U - Jan1Weekday) + (7U * (Jan1Weekday > thursday))) + (day - 1U) + (7U * (month_or_week - 2));
          
        case dateOnly: //An "ordinal date".
          [dateComps setYear: year];
          [dateComps setMonth: 1];
          [dateComps setDay: 1];
          [dateComps setHour: hour];
          [dateComps setMinute: minute];
          [dateComps setSecond: second];
          date = [gregorian dateFromComponents: dateComps];
          [dateComps setYear: 0];
          [dateComps setMonth: 0];
          [dateComps setDay: (day - 1)];
          [dateComps setHour: 0];
          [dateComps setMinute: 0];
          [dateComps setSecond: 0];
          date = [gregorian dateByAddingComponents: dateComps toDate: date options: 0];
          break;
      }
    }
  } //if(!(strict && isdigit(ch[0])))
  
  if(outRange) {
    if(isValidDate)
      range.length = ch - start_of_date;
    else
      range.location = NSNotFound;
    
    *outRange = range;
  }
  
  [gregorian release];

  return date;
}

+ (NSDate *)dateWithString:(NSString *)str {
  return [self dateWithString:str strictly:NO getRange:NULL];
}
+ (NSDate *)dateWithString:(NSString *)str strictly:(BOOL)strict {
  return [self dateWithString:str strictly:strict getRange:NULL];
}
+ (NSDate *)dateWithString:(NSString *)str strictly:(BOOL)strict getRange:(out NSRange *)outRange {
  return [self dateWithString:str strictly:strict timeSeparator:ISO8601ParserDefaultTimeSeparatorCharacter getRange:NULL];
}

+ (NSDate *)dateWithString:(NSString *)str timeSeparator:(unichar)timeSep getRange:(out NSRange *)outRange {
  return [self dateWithString:str strictly:NO timeSeparator:timeSep getRange:outRange];
}
+ (NSDate *)dateWithString:(NSString *)str timeSeparator:(unichar)timeSep {
  return [self dateWithString:str strictly:NO timeSeparator:timeSep getRange:NULL];
}
+ (NSDate *)dateWithString:(NSString *)str getRange:(out NSRange *)outRange {
  return [self dateWithString:str strictly:NO timeSeparator:ISO8601ParserDefaultTimeSeparatorCharacter getRange:outRange];
}

@end
