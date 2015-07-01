//  FSObjectBrowserToolbar.m Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

//  Modified by Philippe mougin

#import "FSObjectBrowserToolbar.h"
#import "FSObjectBrowserToolbarButton.h"
#import "FSObjectBrowserToolbarItem.h"
#import "FSArray.h" 
#import "FSObjectBrowserView.h"
#import "FSInterpreter.h"
#import "FSBlock.h"
#import "FSObjectBrowserSearchField.h"
 
@implementation FSObjectBrowserView (ToolbarController)


- (BOOL)doSetupToolbar
{
  static BOOL yn=YES;
  return yn;
}

- (BOOL)doSetupOldToolbar
{
  static BOOL yn=NO;
  return yn;
}

- (void) setupToolbarWithWindow:(NSWindow *)window
{
  // Create a new toolbar instance, and attach it to our document window
  NSToolbar *toolbar = [[(NSToolbar *)[NSToolbar alloc] initWithIdentifier: @"FSObjectBrowserToolbar"] autorelease];

  // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
  [toolbar setAllowsUserCustomization: YES];
  [toolbar setAutosavesConfiguration: YES];
  [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly]; //  NSToolbarDisplayModeIconAndLabel
  //[toolbar setShowsBaselineSeparator:NO];

  // We are the delegate
  [toolbar setDelegate: self];

  // Attach the toolbar to the document window
  [window setToolbar: toolbar];
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted // Modified by PM for f-script 1.2.3
{
  // Required delegate method   Given an item identifier, self method returns an item
  // The toolbar will use self method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself
  
  NSToolbarItem *toolbarItem; 
  
  if (![[toolbar identifier] isEqualToString:@"FSObjectBrowserToolbar"]) return nil;
  
  if ([itemIdent hasPrefix:@"Custom"])
  {
    NSMenuItem *menuFormRep;
    FSObjectBrowserToolbarButton *button;
    NSInteger i = 0;

    toolbarItem = [[[FSObjectBrowserToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
         
    while (![[[[[self class] customButtons] objectAtIndex:i] identifier] isEqualToString:itemIdent])
      i++;
      
    button = [[[[[self class] customButtons] objectAtIndex:i] copy] autorelease];
    [button setTarget:self]; 
    [toolbarItem setView:button];
    [button setToolbarItem:toolbarItem];
    
    menuFormRep = [[[NSMenuItem alloc] init] autorelease];
    [menuFormRep setAction:@selector(selectedFromMenuItem:)];
    [menuFormRep setTarget:button];
    [menuFormRep setTitle:[button name]];
    [toolbarItem setMenuFormRepresentation: menuFormRep];    
    [toolbarItem setTarget:self];
    [toolbarItem setLabel:[button name]];
    [toolbarItem setPaletteLabel:[button name]];
    
    [toolbarItem setMinSize:[[button cell] cellSize].width < 85 ? NSMakeSize(85, 32) : NSMakeSize([button frame].size.width, 32)];
        
    //[toolbarItem setMaxSize:([button frame].size.width < 93 ? NSMakeSize(93, [button frame].size.height) : [[button cell] cellSize])];
  }
  else if ([itemIdent isEqualToString:@"Filter"])
  {
    FSObjectBrowserSearchField *searchField = [[[FSObjectBrowserSearchField alloc] initWithFrame:NSMakeRect(0,0,93,32)] autorelease];
        
    toolbarItem = [[[FSObjectBrowserToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];
    [toolbarItem setView:searchField];
    [toolbarItem setAction:@selector(filterAction:)];
    [toolbarItem setTarget:self]; 
    [toolbarItem setLabel:@"Filter"];
    [toolbarItem setPaletteLabel:@"Filter"];

    [toolbarItem setMinSize: NSMakeSize(60,32)];
    [toolbarItem setMaxSize: NSMakeSize(150,32)];
  }
  /*else if ([itemIdent isEqualToString:@"RootSelector"])
  {
    NSSegmentedControl *rootSelector = [[[NSSegmentedControl alloc] init] autorelease];
    
    [rootSelector setSegmentCount:2]; 
    
    [rootSelector setLabel:@"Workspace" forSegment:0];
    [rootSelector setLabel:@"Classes"   forSegment:1];
    
    [rootSelector setWidth:85 forSegment:0];
    [rootSelector setWidth:85 forSegment:1];

    toolbarItem = [[[FSObjectBrowserToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];
    
    [toolbarItem setView:rootSelector];
    [toolbarItem setAction:@selector(filterAction:)];
    [toolbarItem setTarget:self]; 
    [toolbarItem setLabel:@"RootSelector"];
    [toolbarItem setPaletteLabel:@"RootSelector"];

    [toolbarItem setMinSize: NSMakeSize(180,32)];
    [toolbarItem setMaxSize: NSMakeSize(180,32)];
  }*/
  else
  {
    NSString *buttonTitle=nil;
    NSString *toolTip=nil;
    SEL action=nil;

    toolbarItem = [[[FSObjectBrowserToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
  
    // defaults
    buttonTitle=itemIdent; 
  
    if ([itemIdent isEqual: @"Classes"]) {
      action=@selector(classesAction:);
      toolTip=@"Browse loaded classes";
    }
    if ([itemIdent isEqual: @"Workspace"]) {
      action=@selector(workspaceAction:);
      toolTip=@"Browse workspace";
    }
    if ([itemIdent isEqual: @"Refresh"]) {
      action=@selector(updateAction:);
      toolTip=@"Update the diplay of objects";
    }
    if ([itemIdent isEqual: @"Name"]) {
      action=@selector(nameObjectAction:);
      toolTip=@"Assign the selected object to an identifier in the F-Script environment";
    }
    if ([itemIdent isEqual: @"Self"]) {
      action=@selector(selfAction:);
      toolTip=@"Send the \"self\" message to the selected object";
    }
    if ([itemIdent isEqual: @"Inspect"]) {
      action=@selector(inspectAction:);
      toolTip=@"Inspect the selected object";
    }
    if ([itemIdent isEqual: @"Key-Value"]) {
      action=@selector(browseKVAction:);
      toolTip=@"Browse the selected object relations";
    }
    if ([itemIdent isEqual: @"Select View"]){
      action=@selector(selectViewAction:);
      toolTip=@"Select a view graphically and browse it";
    }
    if ([itemIdent isEqual: @"Browse"]){
      action=@selector(browseAction:);
      toolTip=@"Open a new object browser for the selected object";
    }

  
    // if it is a button of the above, action is set to non nil.
    if (action) 
    {
      NSMenuItem *menuFormRep = nil;
      NSSegmentedControl *button = [[[NSSegmentedControl alloc] init] autorelease];
	  
	  [button setSegmentCount:1];
	  [button setSegmentStyle:NSSegmentStyleTexturedSquare];
	  //[button setSegmentStyle:NSSegmentStyleCapsule];
	  [button setWidth:80 forSegment:0];
	  [button setLabel:buttonTitle forSegment:0];
	  [[button cell] setTrackingMode:NSSegmentSwitchTrackingMomentary]; 
	  
	  //NSButton *button = [[[NSButton alloc] initWithFrame:NSMakeRect(0,0,93,30)] autorelease];
      //NSButton *button = [[[NSButton alloc] initWithFrame:NSMakeRect(0,0,93,20)] autorelease];
      //[button setBezelStyle:NSRoundedBezelStyle];
      //[button setTitle:buttonTitle];
	  
      [button setAction:action];
      [button setTarget:self];
      [button setToolTip:toolTip];
            
      [toolbarItem setLabel: buttonTitle];
      [toolbarItem setPaletteLabel: buttonTitle];
      [toolbarItem setTarget:self];

      [toolbarItem setView:button];

      [toolbarItem setMinSize:[[button cell] cellSize].width < 85 ? NSMakeSize(85, 32) : NSMakeSize([button frame].size.width, 32)];

      //[toolbarItem setMinSize:[[button cell] cellSize].width < 93 ? NSMakeSize(93, [button frame].size.height) : [[button cell] cellSize]];
      //[toolbarItem setMaxSize:([button frame].size.width < 93 ? NSMakeSize(93, [button frame].size.height) : [[button cell] cellSize])];
      [toolbarItem setToolTip:toolTip];

      menuFormRep = [[[NSMenuItem alloc] init] autorelease];
      [menuFormRep setTitle: buttonTitle];
      [menuFormRep setAction:action];
      [menuFormRep setTarget:[toolbarItem target]];
      [toolbarItem setMenuFormRepresentation: menuFormRep];

    } else if([itemIdent isEqual: @"ApplyBlockMenu"]) {
      NSMenu *submenu = [[self class] customBlockMenu]; // always the same instance (allows us to add to submenu in one place only)
      NSMenuItem *menuFormRep = nil;
      NSRect r=NSMakeRect(0.0,0.0,150.0,30.0);
      NSPopUpButton *popUpButton=[[[NSPopUpButton alloc] initWithFrame:r pullsDown:NO] autorelease];
	  
      [popUpButton setMenu:submenu];
      [popUpButton setTitle:@"Custom Actions"];

      [toolbarItem setToolTip: @"Perform custom browser action"];
      [toolbarItem setLabel: @"Custom Actions"];
      [toolbarItem setPaletteLabel: @"Custom Actions"];
      [toolbarItem setTarget:self];

      [toolbarItem setView:popUpButton];
      [toolbarItem setMinSize:NSMakeSize(150,NSHeight([popUpButton frame]))];
      [toolbarItem setMaxSize:NSMakeSize(250,NSHeight([popUpButton frame]))];
  
      // By default, in text only mode, a custom items label will be shown as disabled text, but you can provide a
      // custom menu of your own by using <item> setMenuFormRepresentation]
      menuFormRep = [[[NSMenuItem alloc] init] autorelease];
      [menuFormRep setSubmenu: submenu];
      [menuFormRep setTitle: [toolbarItem label]];
      [toolbarItem setMenuFormRepresentation: menuFormRep];
    } else {
        // itemIdent refered to a toolbar item that is not provide or supported by us or cocoa
        // Returning nil will inform the toolbar self kind of item is not supported
        toolbarItem = nil;
    }
  }
  return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar 
{
  // Required delegate method   Returns the ordered list of items to be shown in the toolbar by default
  // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
  // user chooses to revert to the default items self set will be used
  return [NSArray arrayWithObjects: @"Filter", @"Workspace", @"Classes", @"Select View", @"Name", @"Inspect", @"Browse", @"Refresh", nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar 
{
  // Required delegate method   Returns the list of all allowed items by identifier   By default, the toolbar
  // does not assume any items are allowed, even the separator   So, every allowed item must be explicitly listed
  // The set of allowed items is used to construct the customization palette
  
  return [NSArray arrayWithObjects: @"Workspace", @"Classes", @"Select View", @"Name", @"Inspect", @"Browse",
                                    @"Refresh", @"Filter", @"Custom1", @"Custom2", @"Custom3", @"Custom4", 
                                    @"Custom5", @"Custom6", @"Custom7", @"Custom8", @"Custom9", @"Custom10", /* @"ApplyBlockMenu",*/
                                    NSToolbarCustomizeToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, 
                                    NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}
 

- (void)toolbarDidRemoveItem:(NSNotification *)notification 
{
    NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];
    if ([[removedItem itemIdentifier] isEqual:@"Filter"]) 
    {
      [(NSSearchField*)[removedItem view] setStringValue:@""];
      [self filterAction:[removedItem view]];
    }
}

+ (NSMenu *) customBlockMenu
{
  static NSMenu *menu=nil;
  if (!menu) {
    menu=[[NSMenu alloc] initWithTitle:@"ApplyBlock"];
  }
  return menu;
}

+ (void) addCustomBlockMenuIdentifier:(NSString *)blockIdentifier
{
  NSMenu *menu=[self customBlockMenu];
  NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:blockIdentifier action:@selector(customBlockMenuAction:) keyEquivalent:@""] autorelease];
  [menu addItem:item];
}
+ (void) removeCustomBlockMenuIdentifier:(NSString *)blockIdentifier
{
  NSMenu *menu=[self customBlockMenu];
  NSInteger idx=[menu indexOfItemWithTitle:blockIdentifier];
  if (idx!=NSNotFound)
    [menu removeItemAtIndex:idx];
  else
    NSLog(@"Warning: removeCustomBlockMenuIdentifier called with invalid blockIdentifier %@",blockIdentifier);
}
- (void) customBlockMenuAction:(id)sender
{
  BOOL found;
  NSString *title=[sender title];
//  id selectedObject = [self selectedObject];
  id block=[interpreter objectForIdentifier:title found:&found];
  if (!found) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Cancel"]; //default
    [alert addButtonWithTitle:@"Remove Menu Entry"]; //alternate
    [alert setMessageText:@"Undefined block"];
    [alert setInformativeText:[NSString stringWithFormat:@"Could not find block with name %@", title]];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertSecondButtonReturn) {
      [[self class] removeCustomBlockMenuIdentifier:title];
    }
  } else {
//    [block value:selectedObject];
    [block value:self]; // allow anything with the browser
  }
}
@end
