//
//  FSObjectBrowserWindow.m
//  FScript
//
//  Created by Anthony Dervish on 08/12/2014.
//
//

#import "FSObjectBrowserWindow.h"
#import "FSObjectBrowserButtonsInspector.h"

@implementation FSObjectBrowserWindow

- (void)sendEvent:(NSEvent *)theEvent
{
  // Goal: route most key events directly to the searchfield
 
  if ([theEvent type] == NSKeyDown)
  {
    unichar character = [[theEvent characters] characterAtIndex:0];
    if (character != NSLeftArrowFunctionKey && character != NSRightArrowFunctionKey && character != NSUpArrowFunctionKey && character != NSDownArrowFunctionKey)    
    {
      NSSearchField *searchField = [self visibleSearchField]; 
      if (searchField && [searchField currentEditor] == nil) // If the searchfield is not already active then we make it become the first responder
        [self makeFirstResponder:searchField];
    }
  }  
  [super sendEvent:theEvent];
}

- (void)runToolbarCustomizationPalette:(id)sender
{
  if (!self.buttonsInspector) {
    self.buttonsInspector = [[FSObjectBrowserButtonsInspector alloc] init];
  }
  [super runToolbarCustomizationPalette:sender];
  [self.buttonsInspector activate];
}

- (BOOL)worksWhenModal
{
  // Since F-Script is often used as a debugging tool, we want it to 
  // continue working even when some other window is being run modally
  return YES;
}

@end
