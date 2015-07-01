//  FSDetailedObjectInspector.m Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import "FSDetailedObjectInspector.h"
#import "FSMiscTools.h"
#import "FSInterpreter.h"
#import "FSObjectInspectorViewModelItem.h"
#import "FSObjectInspectorViewController.h"
#import "FSObjectBrowserViewObjectInfo.h"
#import "FSUtils.h"

static NSPoint sTopLeftPoint = { 0, 0 }; // Used for cascading windows.
static BOOL sIsFirstWindow = YES;
static void *TREE_OBSERVATION_CONTEXT = &TREE_OBSERVATION_CONTEXT;

@interface NSTreeNode (FSTraversal)
-(void)fs_visitNodesWithBlock:(void(^)(NSTreeNode*node))block;
@end
@implementation NSTreeNode (FSTraversal)
-(void)fs_visitNodesWithBlock:(void(^)(NSTreeNode*node))block
{
        assert(block && "block cannot be nil");
        block(self);
        for (NSTreeNode *child in self.childNodes) {
                [child fs_visitNodesWithBlock:block];
        }
}
@end



@interface FSDetailedObjectInspector ()
@property (strong,readwrite,nonatomic) NSWindow *window;
@property (strong,nonatomic) FSObjectInspectorViewController *viewController;
@property (strong,nonatomic) FSObjectInspectorViewModelItem *rootViewModelItem;
@end

@implementation FSDetailedObjectInspector {
}

+ (FSDetailedObjectInspector*)detailedObjectInspectorWithObject:(id)object interpreter:(FSInterpreter*)interpreter
{
        return [[self alloc] initWithObject:object interpreter:(FSInterpreter*)interpreter];
}

- (FSDetailedObjectInspector *)initWithObject:(id)object interpreter:(FSInterpreter*)interpreter
{
        if ((self = [super init])) {
                NSPanel* panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(100.0, 100.0, 500.0, 300.0)
                                                            styleMask:(NSClosableWindowMask | NSTitledWindowMask | NSResizableWindowMask)
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO];
                panel.delegate = self;
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_10
                panel.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
#endif
                self.interpreter = interpreter;
                self.window = panel;
                
                _inspectedObject = object;
                FSObjectInspectorViewController *objectInspectorViewController = [[FSObjectInspectorViewController alloc] initWithNibName:@"FSObjectInspectorViewController" bundle:[NSBundle bundleForClass:self.class]];
                self.viewController = objectInspectorViewController;
                objectInspectorViewController.inspector = self;
                objectInspectorViewController.interpreter = self.interpreter;
                [self refreshModel:self];
                panel.contentView = objectInspectorViewController.view;
                NSSize desiredSize = self.viewController.desiredSize;
                [panel setFrame:[panel frameRectForContentRect:rectWithSize(desiredSize)] display:YES];
                sTopLeftPoint = [self.window cascadeTopLeftFromPoint:sTopLeftPoint];
                if (sIsFirstWindow) {
                        sIsFirstWindow = NO;
                        sTopLeftPoint = [self.window cascadeTopLeftFromPoint:sTopLeftPoint];
                }
                [self.window makeKeyAndOrderFront:nil];
                return self;
        }
        return nil;
}


-(void)dealloc
{
        //NSLog(@"Dealloc %@",self);
        [self _unwatchItems];
}


-(IBAction)refreshModel:(id)sender
{
        [self.window setTitle:[NSString stringWithFormat:@"Inspecting %@ at address %p", descriptionForFSMessage(self.inspectedObject), self.inspectedObject]];
        FSObjectBrowserViewObjectHelper *objectInfoHelper = [FSObjectBrowserViewObjectHelper new];
        [objectInfoHelper introspectPropertiesOfObject:self.inspectedObject];
         [objectInfoHelper populateModelWithObject:self.inspectedObject];
        self.rootViewModelItem = objectInfoHelper.rootViewModelItem;
        self.viewController.rootViewModelItem = self.rootViewModelItem;
}
- (IBAction)browseAction:(id)sender
{
        [self.interpreter browse:self.inspectedObject];
}

/////////////////// Window delegate callbacks

- (void)windowWillClose:(NSNotification*)aNotification
{
}

/*
 *
 *
 *================================================================================================*/
#pragma mark - Properties
/*==================================================================================================
 */


-(void)setRootViewModelItem:(FSObjectInspectorViewModelItem *)rootViewModelItem
{
        [self _unwatchItems];
        _rootViewModelItem = rootViewModelItem;
        [self _watchItems];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
        if (context == TREE_OBSERVATION_CONTEXT) {
                NSLog(@"Value changed for %@. Change = %@", object, change);
                id target = self.inspectedObject;
                FSObjectInspectorViewModelItem *item = object;
                @try {
                        if (item.setter) {
                                if (item.valueType == FS_ITEM_OBJECT
                                    || item.valueType == FS_ITEM_RECT
                                    || item.valueType == FS_ITEM_SIZE
                                    || item.valueType == FS_ITEM_RANGE
                                    || item.valueType == FS_ITEM_POINT
                                    ) {
                                        item.setter(target, item.value, item);
                                        NSLog(@"[%@ setValue:%@ forKey:%@",target,item.value,item.getter);
                                }
                                else {
                                        item.setter(target, @(item.numValue), item);
                                        NSLog(@"[%@ setValue:%@ forKey:%@",target,@(item.numValue),item.getter);
                                }
                        }
                }
                @catch(NSException *e) {
                        NSLog(@"Exception when setting value for key %@ on %@: %@", keyPath, target, e);
                }
        }
}
/*
 *
 *
 *================================================================================================*/
#pragma mark - Utilities
/*==================================================================================================
 */


-(void)_watchItems
{
        [self.rootViewModelItem fs_visitNodesWithBlock:^(NSTreeNode *node) {
                [node addObserver:self
                       forKeyPath:@"value"
                          options:0
                          context:TREE_OBSERVATION_CONTEXT];
        }];
}
-(void)_unwatchItems
{
        [self.rootViewModelItem fs_visitNodesWithBlock:^(NSTreeNode *node) {
                [node removeObserver:self
                          forKeyPath:@"value" ];
        }];
}

@end
