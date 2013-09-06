/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "ScanSnapURLHandler.h"

@implementation ScanSnapURLHandler

#pragma mark - URLHandlerProtocol

/**
 * Can we handle the passed-in URL?
 */
- (BOOL)canHandleURL:(NSURL *)url
{
    // Can't use iOS URL functions as the ScanSnap URLs aren't particularly compliant
    NSString *urlString = [url absoluteString];
    return ([urlString rangeOfString:@"PFUFILELISTFORMAT"].location != NSNotFound);
}

/**
 * We've been told to handle the inbound URL.
 * Parse the URL and generate a list of names of scanned files, then fire a notification.
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSDictionary *parameters = [self queryPairs:url];
    
    // TODO: Check for error
    
    // File count
    NSString *fileCountParam = [parameters objectForKey:@"FileCount"];
    int fileCount = MAX(1, [fileCountParam integerValue]);

    // File list
    NSMutableArray *fileList = [NSMutableArray arrayWithCapacity:fileCount];
    
    for (int i = 1; i < fileCount + 1; i++)
    {
        NSString *fileOfNum = [NSString stringWithFormat:@"File%i", i];
        NSString *fileName = [parameters objectForKey:fileOfNum];
        if (!fileName)
        {
            // FileCount != number of files
            return NO;
        }
        
        [fileList addObject:fileName];
    }
    
    NSDictionary *userInfo = @{@"files" : fileList};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAcquiredScan object:nil userInfo:userInfo];
    
    return YES;
}

/**
 * Parses the url for name/value pairs.
 * If a single value is found, the name is generated from the loop index
 */
- (NSDictionary *)queryPairs:(NSURL *)url
{
    NSArray *pairs = [[url absoluteString] componentsSeparatedByString:@"&"];
    NSMutableDictionary *queryPairs = [NSMutableDictionary dictionary];
    for (int i = 0; i < pairs.count; i++)
    {
        NSString *pair = pairs[i];
        NSArray *nameValue = [pair componentsSeparatedByString:@"="];
        if (0 == [nameValue count])
        {
            continue;
        }

        NSString *name = (NSString *)[nameValue objectAtIndex:0];
        name = [name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSString *value = @"";
        if ([nameValue count] > 1)
        {
            value = (NSString *)[nameValue objectAtIndex:1];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            value = [name copy];
            name = [NSString stringWithFormat:@"%i", i];
        }
        
        [queryPairs setObject:value forKey:name];
    }
    
    return queryPairs;
}

@end
