/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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

#import "AppDelegate.h"
#import "URLHandlerProtocol.h"
#import "ScanSnapURLHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Seems to be necessary (scansnap sdk bug?)
    NSURL *inboundUrl = [url copy];
    NSArray *urlHandlers = @[
                             // Handler for inbound ScanSnap URLs
                             [[ScanSnapURLHandler alloc] init]
                             ];
    
    // Loop through handlers for the first one that claims to support the inbound url
    for (id<URLHandlerProtocol>handler in urlHandlers)
    {
        if ([handler canHandleURL:inboundUrl])
        {
            return [handler handleURL:inboundUrl sourceApplication:sourceApplication annotation:annotation];
        }
    }
    
    return NO;
}

@end
