//  FSObjectBrowserView.h Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class FSInterpreter;
@class FSObjectBrowserBottomBarTextDisplay;
@class FSObjectInspectorViewModelItem;

NSInteger FSCompareClassNamesForAlphabeticalOrder(NSString* className1, NSString* className2, void* context);

const int FSObjectBrowserBottomBarHeight;

@interface FSObjectBrowserView : NSView <NSBrowserDelegate, NSToolbarDelegate> {
        id rootObject;
        FSInterpreter* interpreter;
        NSBrowser* browser;
        FSObjectBrowserBottomBarTextDisplay* bottomBarTextDisplay;
        id selectedView;
        NSString* filterString;
        NSMutableSet* matrixes;
        enum { FSBrowsingWorkspace,
               FSBrowsingClasses,
               FSBrowsingObject,
               FSBrowsingNothing } browsingMode;
}

+ (NSArray*)customButtons;
+ (void)saveCustomButtonsSettings;

- (void)addDictionary:(NSDictionary*)d withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject;
- (void)addBindingForObject:(id)object withName:(NSString*)name toMatrix:(NSMatrix*)matrix classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject;
- (void)addBlankRowToMatrix:(NSMatrix*)matrix;
- (void)addClassLabel:(NSString*)label toMatrix:(NSMatrix*)matrix;
- (void)addClassLabel:(NSString*)label toMatrix:(NSMatrix*)matrix color:(NSColor*)color;
- (void)addClassesWithNames:(NSArray*)classNames withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject;
- (void)addLabel:(NSString*)label toMatrix:(NSMatrix*)matrix;
- (void)addLabel:(NSString*)label toMatrix:(NSMatrix*)matrix indentationLevel:(NSUInteger)indentationLevel;
- (void)addLabelAlone:(NSString*)label toMatrix:(NSMatrix*)matrix;
- (void)addObject:(id)object toMatrix:(NSMatrix*)matrix label:(NSString*)label classLabel:(NSString*)classLabel;
- (void)addObject:(id)object toMatrix:(NSMatrix*)matrix label:(NSString*)label classLabel:(NSString*)classLabel indentationLevel:(NSUInteger)indentationLevel;
- (void)addObject:(id)object toMatrix:(NSMatrix*)matrix label:(NSString*)label classLabel:(NSString*)classLabel indentationLevel:(NSUInteger)indentationLevel leaf:(BOOL)leaf;
- (void)addObject:(id)object withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject;
- (void)addObject:(id)object withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix leaf:(BOOL)leaf classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject indentationLevel:(NSUInteger)indentationLevel;
- (void)addObjects:(NSArray*)objects withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix classLabel:(NSString*)classLabel selectedClassLabel:(NSString*)selectedClassLabel selectedLabel:(NSString*)selectedLabel selectedObject:(id)selectedObject;
- (void)addPropertyLabel:(NSString*)label toMatrix:(NSMatrix*)matrix;
- (IBAction)browseAction:(id)sender;
- (void)browseNothing;
- (void)browseWorkspace;
- (void)fillMatrix:(NSMatrix*)matrix withMethodsForObject:(id)object;
- (void)filterAction:(id)sender;
- (BOOL)hasEmptyFilterString;
- (id)initWithFrame:(NSRect)frameRect;
- (id)selectedObject;
@property (retain,nonatomic) IBOutlet FSInterpreter *interpreter;
@property (retain,nonatomic) IBOutlet id rootObject;

@end
