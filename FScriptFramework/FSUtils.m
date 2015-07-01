//
//  FSUtils.m
//  FScript
//
//  Created by Anthony Dervish on 18/11/2014.
//
//

#import "FSUtils.h"
#import "FSInterpreterResult.h"
#import <Cocoa/Cocoa.h>

@implementation FSUtils
@end

BOOL checkInterpreterResult(FSInterpreterResult* interpreterResult)
{
        if (![interpreterResult isOK]) {
                NSRunAlertPanel(@"Error", [interpreterResult errorMessage], @"OK", nil, nil, nil);
                [interpreterResult inspectBlocksInCallStack];
                return NO;
        }
        return YES;
}
