//  FSObjectBrowser.m Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import "build_config.h" 
#import "FSObjectBrowser.h"
#import "FSObjectBrowserView.h"
#import "FSObjectBrowserToolbar.h"
#import "FSObjectBrowserWindow.h"
#import "FSObjectBrowserButtonsInspector.h"
#import "FSMiscTools.h"
     
static FSObjectBrowserButtonsInspector *buttonsInspector;
static NSPoint topLeftPoint = {0,0}; // Used for cascading windows.
static NSMutableArray *sObjectBrowsers;

@interface FSObjectBrowser ()
@property (nonatomic) BOOL hasAwoken;
@end

@implementation FSObjectBrowser 
+(NSMutableArray*)objectBrowsers
{
  if (!sObjectBrowsers) {
    sObjectBrowsers = [NSMutableArray new];
  }
  return sObjectBrowsers;
}

+(FSObjectBrowser *)objectBrowserWithRootObject:(id)object interpreter:(FSInterpreter *)interpreter
{
  FSObjectBrowser *newBrowser = [[self alloc] initWithRootObject:object interpreter:interpreter]; // NO autorelease. The window will be released when closed.
  [[self objectBrowsers] addObject:newBrowser];
  return newBrowser;
}
 
- (void) browseWorkspace {
  [self.objectBrowserView browseWorkspace];
}
 

- (NSSearchField *)visibleSearchField
{
  NSArray *visibleItems = [[self.window toolbar] visibleItems];
  for (NSUInteger i = 0, count = [visibleItems count]; i < count; i++)
  {
    if ([[[visibleItems objectAtIndex:i] itemIdentifier] isEqualToString:@"Filter"])
    {
      return (NSSearchField *)[((NSToolbarItem *)[visibleItems objectAtIndex:i]) view];
    }
  }
  return nil;  
}
 
-(FSObjectBrowser *)initWithRootObject:(id)object interpreter:(FSInterpreter *)interpreter
{
  self = [super init];
  if (self) {
    self.rootObject = object;
    self.interpreter = interpreter;
  }
  
  return self;
}

-(void)awakeFromNib
{
  if (!self.hasAwoken) {
    self.hasAwoken = YES;
    // jg added from here
    if ([self.objectBrowserView respondsToSelector:@selector(setupToolbarWithWindow:)]) {
      if ([self.objectBrowserView doSetupToolbar])
        [self.objectBrowserView setupToolbarWithWindow:self.window]; // defined in FSObjectBrowserToolBar.m
    }
    // jg added to here
    NSSearchField *searchField = [self visibleSearchField];
    if (searchField) [self.window setInitialFirstResponder:searchField];
    
    [self.window setAcceptsMouseMovedEvents:YES];
    [(FSObjectBrowserWindow*)self.window setVisibleSearchField:searchField];
    self.objectBrowserView.rootObject = self.rootObject;
    self.objectBrowserView.interpreter = self.interpreter;
    topLeftPoint = [self.window cascadeTopLeftFromPoint:topLeftPoint];
  }
  
}

-(void)windowWillClose:(NSNotification *)notification
{
  self.window.delegate = nil;
  [[FSObjectBrowser objectBrowsers] removeObject:self];
}

-(void)makeKeyAndOrderFront:(id)sender
{
  [self.window makeKeyAndOrderFront:sender];
}

-(NSString *)windowNibName
{
  return @"FSObjectBrowser";
}

-(NSString *)windowNibPath
{
  return [[[NSBundle bundleForClass:FSObjectBrowser.class] URLForResource:@"FSObjectBrowser" withExtension:@"nib"] path ];
}

-(void)floatWindow:(id)sender
{
        if (self.window.level == NSNormalWindowLevel) {
                self.window.level = NSFloatingWindowLevel;
        }
        else {
                self.window.level = NSNormalWindowLevel;
        }
}

-(void)dealloc {
  
}

@end
