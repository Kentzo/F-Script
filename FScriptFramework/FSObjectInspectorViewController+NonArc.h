//
//  FSObjectInspectorViewController+NonArc.h
//  FScript
//
//  Created by Anthony Dervish on 18/11/2014.
//
//

#import <Foundation/Foundation.h>
#import "FSObjectInspectorViewController.h"

@class FSArray, FSBlock;
@interface FSObjectInspectorViewController (NonArc)
- (void)applyBlock:(FSBlock*)block withObject:(id)selectedObject newValue:(id)value;
- (BOOL)sendMessageTo:(id)receiver selectorString:(NSString*)selectorStr arguments:(FSArray*)arguments column:(NSUInteger)column putResultInMatrix:(NSMatrix*)matrix;

@end
