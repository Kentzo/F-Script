//  FSObjectBrowserSearchField.m Copyright (c) 2003-2009 Philippe Mougin.
//  This software is open source. See the license.

#import "FSObjectBrowserSearchField.h"


@implementation FSObjectBrowserSearchField

/*+(void) initialize  
{
  static BOOL tooLate = NO;
  if ( !tooLate ) 
  {  
    NSDictionary *registrationDict = [NSDictionary dictionaryWithObjectsAndKeys:@"YES",@"FScriptDoNotShowSelectorsStartingWithUnderscore",@"YES",@"FScriptDoNotShowSelectorsStartingWithAccessibility",nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDict];
  }
}*/ 

- (id)initWithFrame:(NSRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) 
  {
    NSMenu *cellMenu = [[[NSMenu alloc] initWithTitle:@"Search Menu"] autorelease];
    NSMenuItem *item1, *item2, *item3, *item4, *item5, *item6, *item7 ;

    item1 = [[[NSMenuItem alloc] initWithTitle:@"Recent Searches" action: @selector(limitOne:) keyEquivalent:@""] autorelease];
    [item1 setTag:NSSearchFieldRecentsTitleMenuItemTag];
    [cellMenu insertItem:item1 atIndex:0];

    item2 = [[[NSMenuItem alloc] initWithTitle:@"Recents" action:@selector(limitTwo:) keyEquivalent:@""]  autorelease];
    [item2 setTag:NSSearchFieldRecentsMenuItemTag];
    [cellMenu insertItem:item2 atIndex:1];

    item3 = [[[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(limitThree:) keyEquivalent:@""]  autorelease];
    [item3 setTag:NSSearchFieldClearRecentsMenuItemTag];
    [cellMenu insertItem:item3 atIndex:2];

    item4 = [[[NSMenuItem alloc] initWithTitle:@"No Recent Searches" action:@selector(limitFour:) keyEquivalent:@""]  autorelease];
    [item4 setTag:NSSearchFieldNoRecentsMenuItemTag];
    [cellMenu insertItem:item4 atIndex:3];
    
    //item5 = [[NSMenuItem alloc] initWithTitle:@"Filter Options" action:@selector(dummy) keyEquivalent:@""];
    item5 = (id)[NSMenuItem separatorItem];
    [cellMenu insertItem:item5 atIndex:4];
    
    item6 = [[[NSMenuItem alloc] initWithTitle:@"Do Not Show Selectors Starting With \"_\"" action:@selector(changeUnderscoreFilterPreference:) keyEquivalent:@""] autorelease];
    [item6 setTarget:self];
    [item6 setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"FScriptDoNotShowSelectorsStartingWithUnderscore"] ? NSOnState : NSOffState];
    [cellMenu insertItem:item6 atIndex:5];
    
    item7 = [[[NSMenuItem alloc] initWithTitle:@"Do Not Show Selectors Starting With \"accessibility\"" action:@selector(changeAccessibilityFilterPreference:) keyEquivalent:@""] autorelease];
    [item7 setTarget:self];
    [item7 setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"FScriptDoNotShowSelectorsStartingWithAccessibility"] ? NSOnState : NSOffState];
    [cellMenu insertItem:item7 atIndex:6];
    
    [[self cell] setSearchMenuTemplate:cellMenu]; 
      
    [[self cell] setSendsSearchStringImmediately:YES];
  }
  return self; 
} 

- (void)changeAccessibilityFilterPreference:(id)sender // action
{  
  [sender setState:[sender state] == NSOffState ? NSOnState : NSOffState];
  [[[[self cell] searchMenuTemplate] itemAtIndex:6] setState:[sender state]];  // Seems that the search field uses a cached menu, which is generated (and re-generated at various times) from the template menu. 
                                                                               // Thus, we must update both the state of the sender and the state of the menu item in the template menu.
  [[NSUserDefaults standardUserDefaults] setBool:[sender state] == NSOnState ? YES : NO forKey:@"FScriptDoNotShowSelectorsStartingWithAccessibility"];
  [[NSApplication sharedApplication] sendAction:[self action] to:[self target] from:self];
}

- (void)changeUnderscoreFilterPreference:(id)sender // action
{  
  [sender setState:[sender state] == NSOffState ? NSOnState : NSOffState];
  [[[[self cell] searchMenuTemplate] itemAtIndex:5] setState:[sender state]]; // Seems that the search field uses a cached menu, which is generated (and re-generated at various times) from the template menu. 
                                                                              // Thus, we must update both the state of the sender and the state of the menu item in the template menu.
  [[NSUserDefaults standardUserDefaults] setBool:[sender state] == NSOnState ? YES : NO forKey:@"FScriptDoNotShowSelectorsStartingWithUnderscore"];
  [[NSApplication sharedApplication] sendAction:[self action] to:[self target] from:self];
}


@end
