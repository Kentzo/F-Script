//  FSGenericObjectInspector.h Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import <AppKit/AppKit.h>

@class FSObjectInspectorViewModelItem;
@class FSInterpreter;

@interface FSDetailedObjectInspector : NSObject <NSWindowDelegate>
@property (strong,nonatomic) id inspectedObject;
@property (readonly,nonatomic) NSWindow *window;
@property (strong,nonatomic) FSInterpreter* interpreter;

+ (FSDetailedObjectInspector*)detailedObjectInspectorWithObject:(id)object interpreter:(FSInterpreter*)interpreter;
- (FSDetailedObjectInspector *)initWithObject:(id)object interpreter:(FSInterpreter*)interpreter;

- (void)windowWillClose:(NSNotification *)aNotification;
-(IBAction)refreshModel:(id)sender;
- (IBAction)browseAction:(id)sender;

@end
