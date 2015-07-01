//  FSObjectBrowser.h Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import <AppKit/AppKit.h>

@class FSInterpreter;
@class FSObjectBrowserView;

@interface FSObjectBrowser : NSWindowController <NSWindowDelegate>

+ (FSObjectBrowser *)objectBrowserWithRootObject:(id)object interpreter:(FSInterpreter *)interpreter;
- (void) browseWorkspace;
- (void)dealloc;
- (FSObjectBrowser *)initWithRootObject:(id)object interpreter:(FSInterpreter *)interpreter;

@property (strong,nonatomic) IBOutlet id rootObject;
@property (strong,nonatomic) IBOutlet FSInterpreter* interpreter;
@property (weak,nonatomic) IBOutlet FSObjectBrowserView *objectBrowserView;
-(IBAction)floatWindow:(id)sender;
@end
