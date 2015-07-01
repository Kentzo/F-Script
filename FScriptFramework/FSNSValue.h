/* FSNSValue.h Copyright (c) 2003-2009 Philippe Mougin.   */
/*   This software is open source. See the license.  */  

#import <Foundation/Foundation.h>

@class FSBoolean;

@interface NSValue (FSNSValue) 

///////////////////////////////// USER METHODS /////////////////////////

// Common

- (id)clone __attribute__((deprecated));
- (FSBoolean *)operator_equal:(id)operand;
- (FSBoolean *)operator_tilde_equal:(id)operand;
- (NSString *)printString;

// NSPoint

- (NSRect)corner:(NSPoint)operand;
- (NSRect)extent:(NSPoint)operand;
- (CGFloat)x;
- (CGFloat)y;

// NSRange

+ (NSRange)rangeWithLocation:(NSUInteger)location length:(NSUInteger)length;
- (NSUInteger)length;
- (NSUInteger)location;

// NSRect

- (NSPoint)corner;
- (NSPoint)extent;
- (NSPoint)origin;

// NSSize

+ (NSSize)sizeWithWidth:(CGFloat)width height:(CGFloat)height;
- (CGFloat)height;
- (CGFloat)width;

+ (NSEdgeInsets)edgeInsetsWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
-(CGFloat)top;
-(CGFloat)left;
-(CGFloat)bottom;
-(CGFloat)right;

@end
