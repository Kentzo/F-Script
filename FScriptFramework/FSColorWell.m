//
//  FSColorWell.m
//  FScript
//
//  Created by Anthony Dervish on 20/11/2014.
//
//

#import "FSColorWell.h"

@implementation FSColorWell

- (void)drawRect:(NSRect)dirtyRect
{
        [super drawRect:dirtyRect];

        // Drawing code here.
}

- (void)mouseDown:(NSEvent*)theEvent
{
        [self sendAction:self.action to:self.target];
}
@end
