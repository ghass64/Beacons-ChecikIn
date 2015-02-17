/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

#import "UserSettings.h"

@implementation UserSettings
static NSString* const kUserSettingsKeySync = @"kUserSettingsKeySync";
static NSString* const kUserSettingsKeyChecked = @"kUserSettingsKeyChecked";

static NSString* const kUserSettingsKeyAccessToken = @"kUserSettingsKeyAccessToken";
static NSString* const kUserSettingsKeyPushToken = @"kUserSettingsKeyPushToken";

NSString* embededToken;
NSMutableData * _receivedData;
NSURLResponse* _response;

+ (void)setSyncHasBeenShown:(BOOL)hasBeenShown
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:hasBeenShown forKey:kUserSettingsKeySync];
    [prefs synchronize];
}

+ (BOOL)syncHasBeenShown
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL hasBeenShown = [prefs boolForKey:kUserSettingsKeySync];
    return hasBeenShown;
}


+ (void)setCheckIn:(BOOL)hasBeenCheckedIn;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:hasBeenCheckedIn forKey:kUserSettingsKeyChecked];
    [prefs synchronize];
}

+ (BOOL)CheckHasBeenChecked;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL hasBeenCheckedIn = [prefs boolForKey:kUserSettingsKeyChecked];
    return hasBeenCheckedIn;
}


+ (void)setAccessToken:(NSUUID *)token
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (token)
    {
       // NSString* str = token.UUIDString;
        
        [prefs setValue:token.UUIDString forKey:kUserSettingsKeyAccessToken];
    }
    else
    {
        [prefs removeObjectForKey:kUserSettingsKeyAccessToken];
    }
    [prefs synchronize];
}

+ (NSUUID *)accessToken
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* token = [prefs objectForKey:kUserSettingsKeyAccessToken];
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:token];
    if (!uuid) {
        return nil;
        
    }
    return uuid;
    
}

+ (void)setPushToken:(NSString *)pushToken
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (pushToken)
    {
        [prefs setValue:pushToken forKey:kUserSettingsKeyPushToken];
    }
    else
    {
        [prefs removeObjectForKey:kUserSettingsKeyPushToken];
    }
    [prefs synchronize];
}

+ (NSString *)pushToken
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* token = [prefs objectForKey:kUserSettingsKeyPushToken];
    if (!token) {
        //token= @"";
    }
    return token;
}

@end
