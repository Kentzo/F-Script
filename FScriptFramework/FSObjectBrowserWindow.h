//
//  FSObjectBrowserWindow.h
//  FScript
//
//  Created by Anthony Dervish on 08/12/2014.
//
//

#import <Cocoa/Cocoa.h>

@class FSObjectBrowserButtonsInspector;

@interface FSObjectBrowserWindow : NSWindow
@property (strong,nonatomic) NSSearchField *visibleSearchField;
@property (strong,nonatomic) FSObjectBrowserButtonsInspector *buttonsInspector;
@end
