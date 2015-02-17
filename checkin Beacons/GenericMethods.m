//
//  GenericMethods.m
//  Bezaat
//
//  Created by Ghassan ALMarei on 3/4/13.
//  Copyright (c) 2013 Syrisoft. All rights reserved.
//

#import "GenericMethods.h"

@implementation GenericMethods

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   1000
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280


static NSString * documentsDirectoryPath;

+(BOOL) boolValueOfString:(NSString *)str
{
    
    NSString * _true = @"true";
    NSString * trueString = [_true lowercaseString];
    
    if ([[str lowercaseString] isEqualToString:trueString])
        return YES;
    
    return NO;
}

+ (NSString *)stringWithDistance:(double)distance {
    //BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    NSString *format;
    
   // if (isMetric) {
        if (distance < METERS_CUTOFF) {
            format = @"%@ m";
        } else {
            format = @"%@ km";
            distance = distance / 1000;
        }
   // }
    /*else { // assume Imperial / U.S.
        distance = distance * METERS_TO_FEET;
        if (distance < FEET_CUTOFF) {
            format = @"%@ feet";
        } else {
            format = @"%@ miles";
            distance = distance / FEET_IN_MILES;
        }
    }*/
    
    return [NSString stringWithFormat:format, [self stringWithDouble:distance]];
}

// Return a string of the number to one decimal place and with commas & periods based on the locale.
+ (NSString *)stringWithDouble:(double)value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
}


+ (NSString *) getDocumentsDirectoryPath {
    if (!documentsDirectoryPath)
    {
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        documentsDirectoryPath = [pathArray objectAtIndex:0];

    }
    return documentsDirectoryPath;
}

+ (BOOL) fileExistsInDocuments:(NSString *) fileName {
    
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", [GenericMethods getDocumentsDirectoryPath], fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];

    return fileExists;
}


+ (NSDate *) NSDateFromDotNetJSONString:(NSString *) string {
    
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSTextCheckingResult *regexResult = [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult) {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        // timezone offset
        if ([regexResult rangeAtIndex:2].location != NSNotFound) {
            NSString *sign = [string substringWithRange:[regexResult rangeAtIndex:2]];
            // hours
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:3]]] doubleValue] * 60.0 * 60.0;
            // minutes
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:4]]] doubleValue] * 60.0;
        }
        
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    return nil;
}

+ (NSString *) machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString*) reverseString:(NSString *) input {
    
    NSMutableString *reversedStr;
    int len = [input length];
    
    // auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];
    
    // quick-and-dirty implementation
    while ( len > 0 )
        [reversedStr appendString:[NSString stringWithFormat:@"%C",[input characterAtIndex:--len]]];
    
    return reversedStr;
}

+ (NSString *) formatPrice:(float) num {
    
    if ((int) num == 0)
        return @"";
    
    NSString * numStr = [NSString stringWithFormat:@"%i", (int) num ];
    
    NSString * inputStr = [GenericMethods reverseString:numStr];
    
    NSString * outputStr = @"";
    for (int i = 0; i < inputStr.length; i++)
    {
        int remainder = (i+1) % 3;
        if (( remainder == 0 ) && (i != 0) && (i != (inputStr.length -1) ))
            outputStr = [outputStr stringByAppendingFormat:@"%c,", [inputStr characterAtIndex:i]];
        else
            outputStr = [outputStr stringByAppendingFormat:@"%c", [inputStr characterAtIndex:i]];
    }
    return [GenericMethods reverseString:outputStr];
}

+ (NSInteger) dateDifferenceInMinutesFrom:(NSDate *) dateFrom To:(NSDate *) dateTo {
    
    NSTimeInterval distanceBetweenDates = [dateTo timeIntervalSinceDate:dateFrom];
    
    double minutesInAnHour = 60;
    NSInteger minutesBetweenDates = distanceBetweenDates / minutesInAnHour;
    
    return minutesBetweenDates;
}


+ (BOOL) cacheTimingList:(NSArray*)timing
{
    //1- get the file name same as request url
    NSString * cacheFileName = [self getCacheFileNameForTimingList];
    
    //2- get cache file path
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [GenericMethods getDocumentsDirectoryPath], cacheFileName];
    
    //2- check if file exists
    //BOOL cahcedFileExists = [GenericMethods fileExistsInDocuments:cacheFileName];
    
    //3- create the dictionary to be serialized to JSON
    NSMutableDictionary * dictToBeWritten = [NSMutableDictionary new];
    [dictToBeWritten setObject:timing forKey:@"TimingList"];
    
    //4- convert dictionary to NSData
    NSError  *error;
    NSData * dataToBeWritten = [NSKeyedArchiver archivedDataWithRootObject:dictToBeWritten];
    if (![dataToBeWritten writeToFile:cacheFilePath options:NSDataWritingAtomic error:&error])
        return NO;
    else
        return YES;
    
}

+ (NSString *) getCacheFileNameForTimingList
{
    
    //the file name is the string of listing URL without the page number and page size
    NSString * fullURLString = @"/TimingList";
    
    NSString * correctURLstring = [fullURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    
    return [[correctURLstring componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

+ (NSArray *) getCachedTimingList {
    
    //1- get the file name same as request url
    NSString * cacheFileName = [self getCacheFileNameForTimingList];
    
    //2- get cache file path
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [GenericMethods getDocumentsDirectoryPath], cacheFileName];
    
    //check if the file expiration date
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:cacheFilePath error:nil];
    
    if (attrs) {
        
        NSDate * today = [NSDate date];
        //NSDate * fileCreationDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSDate * fileModificationDate = [attrs fileModificationDate];
        
        NSInteger minutesDiff = [GenericMethods dateDifferenceInMinutesFrom:fileModificationDate To:today];
        
        
         //NSLog(@"File last modified on: %@", fileModificationDate);
         //NSLog(@"today is: %@", today);
         //NSLog(@"difference in minutes is: %li", (long)minutesDiff);
         
         
         if (minutesDiff > 7200) {
         NSError *error;
         if ([fm removeItemAtPath:cacheFilePath error:&error] == YES)
         //NSLog(@"File exceeded expiration limit, file has bee deleted");
         
         return nil;
         }
         
        
    }
    
    NSData *archiveData = [NSData dataWithContentsOfFile:cacheFilePath];
    if (!archiveData)
        return nil;
    
    NSDictionary * dataDict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    
    if (!dataDict)
        return nil;
    
    NSArray * resultNum = [dataDict objectForKey:@"TimingList"];
    return resultNum;
}

+ (void) clearCachedTimingList {
    
    //1- get the file name same as request url
    NSString * cacheFileName = [self getCacheFileNameForTimingList];
    
    //2- get cache file path
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [GenericMethods getDocumentsDirectoryPath], cacheFileName];
    
    //check if the file expiration date
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSError *error;
    
    [fm removeItemAtPath:cacheFilePath error:&error];
    
}

@end
