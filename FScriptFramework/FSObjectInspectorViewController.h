//
//  FSObjectInspectorViewController.h
//  FScript
//
//  Created by Anthony Dervish on 17/11/2014.
//
//

#import <Cocoa/Cocoa.h>

@class FSObjectInspectorViewModelItem;
@class FSInterpreter;
@class FSDetailedObjectInspector;

@interface FSObjectInspectorViewController : NSViewController <NSOutlineViewDelegate, NSPopoverDelegate>
@property (assign) IBOutlet NSPathControl *viewPathControl;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (weak,nonatomic) FSDetailedObjectInspector *inspector;
@property (strong,nonatomic) FSObjectInspectorViewModelItem *rootViewModelItem;
@property (weak,nonatomic) FSObjectInspectorViewModelItem *selectedViewModelItem;
@property (readonly,nonatomic) NSSize desiredSize;
@property (strong,nonatomic) FSInterpreter *interpreter;
@property (strong,nonatomic) NSMenu *viewPathMenu;
@property (strong,nonatomic) NSArray *pathControlItems;
-(IBAction)showColorPanel:(id)sender;
-(IBAction)showOptionsPopover:(id)sender;
-(IBAction)inspectAction:(id)sender;
-(IBAction)viewPathClicked:(id)sender;
@end
