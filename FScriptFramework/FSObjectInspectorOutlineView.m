//
//  FSObjectInspectorOutlineView.m
//  FScript
//
//  Created by Anthony Dervish on 21/11/2014.
//
//

#import "FSObjectInspectorOutlineView.h"

@implementation FSObjectInspectorOutlineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

// Allow stepper views to work properly
- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event {
  return YES;
}

@end
