//
//  FSObjectInspectorOptionsViewController.h
//  FScript
//
//  Created by Anthony Dervish on 21/11/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface FSObjectInspectorOptionsViewController : NSViewController
@property (assign) IBOutlet NSArrayController *optionsArrayController;
@property (copy,nonatomic) NSArray *optionItems;
@end
