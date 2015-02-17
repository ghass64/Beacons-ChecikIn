//
//  GenericMethods.h
//  Bezaat
//
//  Created by Ghassan ALMarei on 3/4/13.
//  Copyright (c) 2013 Syrisoft. All rights reserved.
//
// This is a class that provides some generic static helper methods

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

@interface GenericMethods : NSObject


//This method takes a "true/false" string and returns YES/No
+ (BOOL) boolValueOfString:(NSString *) str;

+ (NSString *)stringWithDistance:(double)distance;

+ (NSString *)stringWithDouble:(double)value;


// This method gets the string path of documents directory
+ (NSString *) getDocumentsDirectoryPath;

// This method searches for a file in documnts path
+ (BOOL) fileExistsInDocuments:(NSString *) fileName;

// This method parses a JSON like date string into an NSDate
+ (NSDate *) NSDateFromDotNetJSONString:(NSString *) string;

// This method returns the device name and version
+ (NSString *) machineName;

// This method gives the reverse of a string
+ (NSString*) reverseString:(NSString *) input;

// This method formats the price value to remove the floating point and adds commas after each three digits
+ (NSString *) formatPrice:(float) num;

+ (NSInteger) dateDifferenceInMinutesFrom:(NSDate *) dateFrom To:(NSDate *) dateTo;
//CACHE contact list
+ (BOOL) cacheTimingList:(NSArray*)timing;

+ (NSArray *) getCachedTimingList;

+ (void) clearCachedTimingList;

+ (NSString *) getCacheFileNameForTimingList;

@end
