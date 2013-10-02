/*
 
 Copyright (c) 2012, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */


#import "OpenPeerUtility.h"
#import <zsLib/Log.h>
#include <zsLib/helpers.h>

ZS_DECLARE_SUBSYSTEM(openpeer_sdk)

void OpenPeerLog(HOPLoggerLevels logLevel, NSString* format,...)
{
    va_list argumentList;
    va_start(argumentList, format);
    NSString *fullString = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    
    switch (logLevel)
    {
        case HOPLoggerLevelBasic:
            ZS_LOG_BASIC(zsLib::String("SDK: ") + [fullString UTF8String]);
            break;
            
        case HOPLoggerLevelDetail:
            ZS_LOG_DETAIL(zsLib::String("SDK: ") + [fullString UTF8String]);
            break;
            
        case HOPLoggerLevelDebug:
            ZS_LOG_DEBUG(zsLib::String("SDK: ") + [fullString UTF8String]);
            break;
            
        case HOPLoggerLevelTrace:
            ZS_LOG_TRACE(zsLib::String("SDK: ") + [fullString UTF8String]);
            break;
        
        case HOPLoggerLevelNone:
        default:
            break;
    }
}

@implementation OpenPeerUtility

+ (NSDate*) convertPosixTimeToDate:(boost::posix_time::ptime) time
{
    boost::posix_time::ptime epoch(boost::gregorian::date(1970,1,1) );
    const boost::posix_time::time_duration::sec_type x((time - epoch).total_seconds() );
    return[NSDate dateWithTimeIntervalSince1970:x];
}

+ (NSString*) getBaseIdentityURIFromURI:(NSString*) identityURI
{
    NSString* ret = @"";
    NSArray* identityParts = [identityURI componentsSeparatedByString:@"/"];
    if ([identityParts count] > 3)
    {
        int maxCount = [identityParts count] - 1;
        for (int i = 0; i < maxCount; i++)
        {
            ret = [ret stringByAppendingFormat:@"%@/",[identityParts objectAtIndex:i]];
        }
    }
    return ret;
}

+ (NSString*) getContactIdFromURI:(NSString*) identityURI
{
    {
        NSString* ret = @"";
        NSArray* identityParts = [identityURI componentsSeparatedByString:@"/"];
        if ([identityParts count] > 3)
        {
            int index = [identityParts count] - 1;
            ret = [identityParts objectAtIndex:index];
        }
        return ret;
    }
}

+ (BOOL) isBaseIdentityURI:(NSString*) identityURI
{
    BOOL ret = YES;
    NSArray* identityParts = [identityURI componentsSeparatedByString:@"/"];
    if ([identityParts count] > 3)
    {
        int index = [identityParts count] - 1;
        ret = [[identityParts objectAtIndex:index] length] == 0;
    }
    return ret;
}

static void OpenPeerLog(NSString* format,...)
{
    
}
@end
