/* FSCollectionInspector.m Copyright (c) 1998-2009 Philippe Mougin.  */
/*   This software is open source. See the license.             */  

#import "build_config.h"
#import "FSCollectionInspector.h"
#import "FSBlock.h" // value: 
#import "FSMiscTools.h"
#import "FSInterpreter.h"
#import <AppKit/AppKit.h>
#import "FSArray.h"
#import "FSNSArray.h"
//#import "FSObjectFormatter.h"
#import "Number_fscript.h"
#import "FSNSString.h"
#import "FSCollectionInspectorView.h"

static NSPoint topLeftPoint = {0,0}; // Used for cascading windows.

 
@implementation FSCollectionInspector


+ (FSCollectionInspector *)collectionInspectorWithCollection:(id)theCollection interpreter:(FSInterpreter *)theInterpreter blocks:(NSArray *)blocks showExternals:(BOOL)showExternals
{
  return [[[self alloc] initWithCollection:theCollection interpreter:theInterpreter blocks:blocks showExternals:showExternals] autorelease];
}

+ (FSCollectionInspector *)collectionInspectorWithCollection:(id)theCollection interpreter:(FSInterpreter *)theInterpreter blocks:(NSArray *)blocks 
{
  return [self collectionInspectorWithCollection:theCollection interpreter:theInterpreter blocks:blocks showExternals:YES];
}

- (void)dealloc 
{
  //NSLog(@"FSCollectionInspector dealloc");
  [super dealloc];
}

- (FSCollectionInspector *)initWithCollection:(id)theCollection interpreter:(FSInterpreter *)theInterpreter blocks:(NSArray *)blocks showExternals:(BOOL)showExternals
{
  if (self = [super init])
  {
    [self retain]; // we must stay alive while our window exist cause we are its delegate (and NSWindow doesn't retain its delegate).
 
    [NSBundle loadNibNamed:@"FSCollectionInspector.nib" owner:self];
    [collectionInspectorView setCollection:theCollection interpreter:theInterpreter blocks:blocks showExternals:showExternals];
    
    topLeftPoint = [[collectionInspectorView window] cascadeTopLeftFromPoint:topLeftPoint];
    
    if      ([theCollection isKindOfClass:[NSArray class]])      [[collectionInspectorView window] setTitle:@"Array Inspector"];
    else if ([theCollection isKindOfClass:[NSDictionary class]]) [[collectionInspectorView window] setTitle:@"Dictionary Inspector"];
    else if ([theCollection isKindOfClass:[NSCountedSet class]]) [[collectionInspectorView window] setTitle:@"Counted Set Inspector"];
    else if ([theCollection isKindOfClass:[NSSet class]])        [[collectionInspectorView window] setTitle:@"Set Inspector"];

    [[collectionInspectorView window] makeKeyAndOrderFront:nil]; // We configure the interface in the background before putting the window on screen 
  }
  return self;
}

/////////////////// Window delegate callbacks

- (void)windowWillClose:(NSNotification *)aNotification 
{
  [self autorelease];
} 

@end
