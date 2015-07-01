//
//  FSUtils.h
//  FScript
//
//  Created by Anthony Dervish on 18/11/2014.
//
//

#import <Foundation/Foundation.h>

@interface FSUtils : NSObject

@end


static inline NSRect rectWithWidthAndHeight(CGFloat width, CGFloat height)
{
        return NSMakeRect(0.0, 0.0, width, height);
}
static inline NSRect rectWithSize(NSSize size)
{
        return NSMakeRect(0.0, 0.0, size.width, size.height);
}

static inline NSSize addSizes(NSSize size1, NSSize size2)
{
        return NSMakeSize(size1.width + size2.width, size1.height + size2.height);
}
@class FSInterpreterResult;
BOOL checkInterpreterResult(FSInterpreterResult *result);