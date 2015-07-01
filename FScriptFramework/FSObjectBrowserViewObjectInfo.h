//  FSObjectBrowserViewObjectInfo.h Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import <Cocoa/Cocoa.h>
#import "FSObjectBrowserView.h"

@interface FSObjectBrowserView (FSObjectBrowserViewObjectInfo)

- (void)fillMatrix:(NSMatrix*)m column:(NSUInteger)col withObject:(id)object;
   
@end

@interface FSObjectBrowserViewObjectHelper : NSObject
@property (nonatomic, retain) FSObjectInspectorViewModelItem* rootViewModelItem;
+ (NSArray*)baseClasses;
-(void)introspectPropertiesOfObject:(id)object;
-(void)populateModelWithObject:(id)object;

@end
