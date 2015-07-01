//
//  FSObjectInspectorViewController.m
//  FScript
//
//  Created by Anthony Dervish on 17/11/2014.
//
//

#import "FSObjectInspectorViewController.h"
#import "FSObjectInspectorViewController+NonArc.h"
#import "FSObjectInspectorViewModelItem.h"
#import "FSObjectInspectorOptionsViewController.h"
#import "FSDetailedObjectInspector.h"
#import "FSNamedNumber.h"
#import "FSMiscTools.h"
#import "FSObjectEnumInfo.h"
#import <objc/objc.h>
#import <AvailabilityMacros.h>

#define AppearanceName NSAppearanceNameVibrantDark

@interface FSObjectInspectorViewController ()
@property (nonatomic) BOOL hasAwoken;
@property (nonatomic,strong) NSPopover *optionsPopover;
@end

@interface FSObjectInspectorOption : NSObject
@property (copy,nonatomic) NSString *name;
@property (nonatomic) BOOL state;
@property (nonatomic) NSUInteger value;
@end
@implementation FSObjectInspectorOption
+(FSObjectInspectorOption*)optionWithName:(NSString*)name value:(NSUInteger)value state:(BOOL)on
{
        FSObjectInspectorOption *opt = [FSObjectInspectorOption new];
        opt.name = name;
        opt.state = on;
        opt.value = value;
        return opt;
}

+(NSArray *)arrayFromOptions:(NSUInteger) opts dict:(NSMutableDictionary *)dict mask:(NSUInteger) mask
{
        NSMutableArray* result = [NSMutableArray array];
        for (NSNumber * opt in dict.allKeys) {                                                                                                             
                [result addObject:[FSObjectInspectorOption optionWithName:(NSString*)dict[opt] value:opt.unsignedIntegerValue state:(opts & opt.unsignedIntegerValue)]];
        }
        return result;
}
+(NSUInteger)optionsFromArray:(NSArray /*of FSObjectInspectorOption */ *) opts dict:(NSMutableDictionary *)dict mask:(NSUInteger) mask
{
        NSUInteger result = 0;
        for (FSObjectInspectorOption *opt in opts) {
                if (opt.state) {
                        result |= opt.value;
                }
        }
        return result;
}
@end

/*
 *
 *
 *================================================================================================*/
#pragma mark - FSObjectInspectorViewController Implementation
/*==================================================================================================
 */


@implementation FSObjectInspectorViewController
{
        CGFloat _scrollViewOffsetY;
}
static NSImage * sViewImage = nil;
static NSImage * sWindowImage = nil;

+ (void)initialize
{
        if (self == [FSObjectInspectorViewController class]) {
                sViewImage = [NSImage imageWithSize:NSMakeSize(33.0, 27.0) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
                        //// Color Declarations
                        NSColor* color = [NSColor colorWithCalibratedRed: 0.49 green: 0.827 blue: 0.976 alpha: 1];
                        NSColor* color2 = [NSColor colorWithCalibratedRed: 0.49 green: 0.827 blue: 0.976 alpha: 0.296];
                        NSColor* color3 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
                        
                        //// Group
                        {
                                //// Rectangle Drawing
                                NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect: NSMakeRect(0, 0, 33, 27)];
                                [color setFill];
                                [rectanglePath fill];
                                
                                
                                //// Rectangle 2 Drawing
                                NSBezierPath* rectangle2Path = [NSBezierPath bezierPathWithRect: NSMakeRect(1, 1, 31, 22)];
                                [NSColor.whiteColor setFill];
                                [rectangle2Path fill];
                                
                                
                                //// Rectangle 3 Drawing
                                NSBezierPath* rectangle3Path = [NSBezierPath bezierPathWithRect: NSMakeRect(3, 3, 27, 18)];
                                [color2 setFill];
                                [rectangle3Path fill];
                                
                                
                                //// Oval Drawing
                                NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(2, 24, 2, 2)];
                                [color3 setFill];
                                [ovalPath fill];
                                
                                
                                //// Oval 2 Drawing
                                NSBezierPath* oval2Path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(5, 24, 2, 2)];
                                [color3 setFill];
                                [oval2Path fill];
                                
                                
                                //// Oval 3 Drawing
                                NSBezierPath* oval3Path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(8, 24, 2, 2)];
                                [color3 setFill];
                                [oval3Path fill];
                        }
                        return YES;
                }];
                sWindowImage = sViewImage;
                
        }
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
                _pathControlItems = @[];
        }
        return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_10
        self.view.appearance = [NSAppearance appearanceNamed:AppearanceName];
        self.viewPathControl.appearance = [NSAppearance appearanceNamed:AppearanceName];
#endif
}

- (void)awakeFromNib
{
        if (!self.hasAwoken) {
                self.hasAwoken = YES;
                [self expandAll:self];
                NSScrollView* scrollView = self.outlineView.enclosingScrollView;
                _scrollViewOffsetY = NSHeight(scrollView.superview.bounds) - NSHeight(scrollView.frame);
                self.outlineView.doubleAction = @selector(inspectAction:);
                self.outlineView.target = self;
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_10
                self.outlineView.appearance = [NSAppearance appearanceNamed:AppearanceName];
                if (self.rootViewModelItem.valueClass == NSView.class) {
                        self.viewPathMenu = [self _menuForView:self.rootViewModelItem.value];
                }
                
#endif
        }
}

- (NSSize)desiredSize
{
        NSScrollView* scrollView = self.outlineView.enclosingScrollView;
        NSSize scrollViewSize = [NSScrollView frameSizeForContentSize:self.outlineView.bounds.size
                                              horizontalScrollerClass:scrollView.horizontalScroller.class
                                                verticalScrollerClass:scrollView.verticalScroller.class
                                                           borderType:scrollView.borderType
                                                          controlSize:scrollView.horizontalScroller.controlSize
                                                        scrollerStyle:scrollView.scrollerStyle];
        if (self.outlineView.headerView) {
                scrollViewSize.height += NSHeight(self.outlineView.headerView.bounds);
        }
        scrollViewSize.height += _scrollViewOffsetY;
        return scrollViewSize;
}

-(void)dealloc
{
        //NSLog(@"Dealloc %@",self);
        [NSObject cancelPreviousPerformRequestsWithTarget:self ];
}
-(IBAction)expandAll:(id)sender
{
        [self.outlineView expandItem:nil expandChildren:YES];
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
        if (self.hasAwoken && rootViewModelItem.valueClass == NSView.class) {
                self.viewPathMenu = [self _menuForView:rootViewModelItem.value];
        }
        _rootViewModelItem = rootViewModelItem;
        [self performSelector:@selector(expandAll:) withObject:self afterDelay:0.0];
}

-(FSObjectInspectorOptionsViewController*)optionsViewController
{
        return (FSObjectInspectorOptionsViewController*)self.optionsPopover.contentViewController;
}
-(NSPopover*)optionsPopover
{
        if (_optionsPopover == nil) {
                _optionsPopover = [NSPopover new];
                _optionsPopover.behavior = NSPopoverBehaviorTransient;
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_10
                _optionsPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameLightContent];
#else
                _optionsPopover.appearance = NSPopoverAppearanceHUD;
#endif
                _optionsPopover.contentViewController = [FSObjectInspectorOptionsViewController new];
                _optionsPopover.delegate = self;
        }
        return _optionsPopover;
}
/*
 *
 *
 *================================================================================================*/
#pragma mark - NSOutlineViewDelegate
/*==================================================================================================
 */

- (NSView*)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
        if ([tableColumn.identifier isEqualToString:@"Name"]) {
                return [self.outlineView makeViewWithIdentifier:@"Name" owner:self];
        }
        NSView *view = nil;
        FSObjectInspectorViewModelItem* viewModel = [item representedObject];
        if ([viewModel respondsToSelector:@selector(valueType)]) {
                switch (viewModel.valueType) {
                        case FS_ITEM_HEADER:
                                view = [self.outlineView makeViewWithIdentifier:@"Header" owner:self];
                                break;
                        case FS_ITEM_ENUM:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorEnumView" owner:self];
                                break;
                        case FS_ITEM_OPTIONS:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorOptionsView" owner:self];
                                break;
                        case FS_ITEM_NUMBER:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorNumberView" owner:self];
                                break;
                        case FS_ITEM_SIZE:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorSizeView" owner:self];
                                break;
                        case FS_ITEM_RECT:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorRectView" owner:self];
                                break;
                        case FS_ITEM_OBJECT:
                                view = [self.outlineView makeViewWithIdentifier:[self _viewIdentifierForValueClass:viewModel.valueClass]
                                                                          owner:self];
                                break;
                        case FS_ITEM_POINT:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorReadOnlyView" owner:self];
                                break;
                        case FS_ITEM_RANGE:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorReadOnlyView" owner:self];
                                break;
                        case FS_ITEM_BOOL:
                                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorEnumView" owner:self];
                                break;
                                
                        default:
                                break;
                }
        }
        else {
                view = [self.outlineView makeViewWithIdentifier:@"ObjectInspectorReadOnlyView" owner:self];
        }
        return view;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
        FSInspectorVMValueType vmType = ((FSObjectInspectorViewModelItem*)[item representedObject]).valueType;
        return  vmType == FS_ITEM_HEADER;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
        FSInspectorVMValueType valueType = [(FSObjectInspectorViewModelItem*)[item representedObject] valueType] ;
        return (valueType != FS_ITEM_HEADER && valueType != FS_ITEM_GROUP);
}

/*
 *
 *
 *================================================================================================*/
#pragma mark - Actions
/*==================================================================================================
 */


-(IBAction)setColor:(id)sender
{
        NSColor *color = [(NSColorPanel*)sender color];
        self.selectedViewModelItem.value = color;
}

-(IBAction)showColorPanel:(id)sender
{
        NSInteger row = [self.outlineView rowForView:sender];
        if (row >= 0) {
                [NSColorPanel.sharedColorPanel orderFront:self];
                NSColorPanel.sharedColorPanel.target = self;
                NSColorPanel.sharedColorPanel.action = @selector(setColor:);
                
                self.selectedViewModelItem = [[self.outlineView itemAtRow:row] representedObject];
                
        }
        
}
-(IBAction)inspectAction:(id)sender
{
        NSInteger row = [self.outlineView selectedRow];
        if (row >= 0) {
                FSObjectInspectorViewModelItem *item = [[self.outlineView itemAtRow:row] representedObject];
                if (item.valueType == FS_ITEM_OBJECT && item.valueClass != nil) {
                        inspect(item.value, self.interpreter, nil);
                }
        }
}


-(IBAction)showOptionsPopover:(id)sender
{
        NSInteger row = [self.outlineView rowForView:sender];
        if (row >= 0) {
                NSRect senderFrame = [sender frame];
                FSObjectInspectorViewModelItem *clickedItem = [[self.outlineView itemAtRow:row] representedObject];
                self.selectedViewModelItem = clickedItem;
                NSArray *optionItems = [FSObjectInspectorOption arrayFromOptions:clickedItem.numValue dict:clickedItem.enumBiDict mask:clickedItem.optsMask];
                self.optionsViewController.optionItems = optionItems;
                [self.optionsPopover showRelativeToRect:senderFrame ofView:sender preferredEdge:NSMaxYEdge];
        }
}

-(IBAction)viewPathClicked:(id)sender
{
        if ([NSApp currentEvent].modifierFlags & NSAlternateKeyMask) {
                self.inspector.inspectedObject = [[(NSPathControl*)sender clickedPathComponentCell] representedObject];
                [self.inspector refreshModel:self];
        }
        else {
                id clickedObject = [[(NSPathControl*)sender clickedPathComponentCell] representedObject];
                inspect(clickedObject, self.interpreter, nil);
        }
}
/*
 *
 *
 *================================================================================================*/
#pragma mark - NSPopoverDelegate
/*==================================================================================================
 */

-(void)popoverDidClose:(NSNotification *)notification
{
        
        NSUInteger newOpts = [FSObjectInspectorOption optionsFromArray:self.optionsViewController.optionItems dict:self.selectedViewModelItem.enumBiDict mask:self.selectedViewModelItem.optsMask];
        self.selectedViewModelItem.value = objectFromOptions(newOpts, self.selectedViewModelItem.enumBiDict, self.selectedViewModelItem.optsMask);
}

/*
 *
 *
 *================================================================================================*/
#pragma mark - NSResponder
/*==================================================================================================
 */
-(BOOL)acceptsFirstResponder
{
        return YES;
}
-(id)supplementalTargetForAction:(SEL)action sender:(id)sender
{
        if (action == @selector(refreshModel:)
            || action == @selector(browseAction:))
        {
                return self.inspector;
        }
        return [super supplementalTargetForAction:action sender:sender];
}

/*
 *
 *
 *================================================================================================*/
#pragma mark - Utilities
/*==================================================================================================
 */


-(NSString*)_viewIdentifierForValueClass:(Class)class
{
        if (class == NSColor.class) {
                return @"ObjectInspectorColorView";
        }
        else if (class == NSString.class) {
                return @"ObjectInspectorStringView";
        }
        return @"ObjectInspectorReadOnlyView";
}

-(NSString*)_titleForView:(NSView*)view
{
        return view.description;
}

-(NSImage*)_imageForView:(NSView*)view
{
        return sViewImage;
}

-(NSPathComponentCell*)_pathComponentCellForView:(NSView*)view withURL:(NSURL*)url
{
        NSPathComponentCell *item = [[NSPathComponentCell alloc] initTextCell:[self _titleForView:view]];
        item.controlSize = self.viewPathControl.controlSize;
        item.font = self.viewPathControl.font;
        item.image = [self _imageForView:view];
        item.representedObject = view;
        return item;
}
-(IBAction)viewWasSelectedFromMenu:(id)sender
{
        
}
-(NSMenu*)_menuForSiblingViewsOfView:(NSView*)view select:(BOOL)select
{
        NSAssert([view isKindOfClass:NSView.class], @"Cannot get view hierarchy for a non-view class %@",view);
        NSView *superview = view.superview;
        NSMenu *menu = [[NSMenu alloc] initWithTitle:view.description];
        NSArray *views = superview ? superview.subviews : @[view];
        for (NSView *v in views) {
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[self _titleForView:v] action:@selector(viewWasSelectedFromMenu:) keyEquivalent:@""];
                item.representedObject = v;
                [menu addItem:item];
                if (select && v == view) {
                        [(NSMenuItem*)menu.itemArray.lastObject setState:NSOnState];
                        [(NSMenuItem*)menu.itemArray.lastObject setTag:1];
                        
                }
        }
        return menu;
}

-(NSMenu*)_menuForView:(NSView*)view
{
        
        NSAssert([view isKindOfClass:NSView.class], @"Cannot get view hierarchy for a non-view class %@",view);
        if (!view.superview) { return nil; }
        NSMutableArray * pathControlItems = [NSMutableArray new];
        NSMutableArray *submenus = [NSMutableArray new];
        NSView *v = view;
        NSUInteger submenuCount = 0;
        while (v.superview) {
                NSMenu *submenu = [self _menuForSiblingViewsOfView:v select:YES];
                [submenus addObject:submenu];
                ++submenuCount;
                v = v.superview;
        }
        NSURL *url = [NSURL URLWithString:@"views://"];
        NSMenu *rootMenu = submenus.lastObject;
        NSMenuItem *selectedItem = [rootMenu itemWithTag:1];
        [pathControlItems addObject:[self _pathComponentCellForView:selectedItem.representedObject withURL:url]];
        NSMenu *currentMenu = rootMenu;
        [submenus removeLastObject];
        for (NSMenu *submenu in submenus.reverseObjectEnumerator) {
                selectedItem = [currentMenu itemWithTag:1];
                url = [url URLByAppendingPathComponent:@"view"];
                [pathControlItems addObject:[self _pathComponentCellForView:selectedItem.representedObject withURL:url]];
                [selectedItem setSubmenu:submenu];
                currentMenu = submenu;
        }
        self.viewPathControl.pathComponentCells = pathControlItems.count ? pathControlItems : @[];
        return rootMenu;
}

@end
