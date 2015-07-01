//  FSObjectBrowserMatrix.h Copyright (c) 2002-2009 Philippe Mougin.
//  This software is open source. See the license.

#import <Foundation/Foundation.h>

@class FSObjectInspectorViewModelItem;

@interface FSObjectBrowserMatrix : NSMatrix
@property (strong,nonatomic) FSObjectInspectorViewModelItem *rootViewModelItem;
@end
