/* FSNSValue.m Copyright (c) 2003-2009 Philippe Mougin.   */
/*   This software is open source. See the license.  */  

#import "FSNSValue.h"
#import "FSNSObject.h"
#import "FSNumber.h"
#import "FScriptFunctions.h"
#import "FSBooleanPrivate.h"

@implementation NSValue (FSNSValue) 

/////////////////////////// USER METHODS ////////////////////////////

+ (NSRange)rangeWithLocation:(NSUInteger)location length:(NSUInteger)length
{
  return NSMakeRange(location,length);
}
+ (NSEdgeInsets)edgeInsetsWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right
{
  return NSEdgeInsetsMake(top, left, bottom, right);
}
 
+ (NSSize)sizeWithWidth:(CGFloat)width height:(CGFloat)height
{
  return NSMakeSize(width, height);
}

- (id)clone { return  [[self copy] autorelease];}

- (NSPoint)corner
{
  if (strcmp([self objCType],@encode(NSRect)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"corner\" sent to a number");
    else
      FSExecError(@"message \"corner\" sent to an NSValue that does not contain an NSRect");
  }
  else
  {
    NSRect rectValue = [self rectValue];
    return NSMakePoint(rectValue.origin.x + rectValue.size.width, rectValue.origin.y + rectValue.size.height);
  }
}

- (NSRect)corner:(NSPoint)operand
{
  if (strcmp([self objCType],@encode(NSPoint)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"corner:\" sent to a number");
    else
      FSExecError(@"message \"corner:\" sent to an NSValue that does not contain an NSPoint");
  }
  else
  {
    NSPoint pointValue = [self pointValue];
    if (operand.x < pointValue.x || operand.y < pointValue.y) FSExecError(@"argument 1 of method \"corner:\" must be a valid corner");
    return NSMakeRect(pointValue.x,pointValue.y,operand.x - pointValue.x,operand.y - pointValue.y);
  }
}

- (NSPoint)extent
{
  if (strcmp([self objCType],@encode(NSRect)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"extent\" sent to a number");
    else
      FSExecError(@"message \"extent\" sent to an NSValue that does not contain an NSRect");
  }
  else
  {
    NSRect rectValue = [self rectValue];
    return NSMakePoint(rectValue.size.width,rectValue.size.height);
  }
}

- (NSRect)extent:(NSPoint)operand
{
  if (strcmp([self objCType],@encode(NSPoint)) != 0) 
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"extent:\" sent to a number");
    else
      FSExecError(@"message \"extent:\" sent to an NSValue that does not contain an NSPoint");
  }
  else
  {
    if (operand.x < 0 || operand.y < 0) FSExecError(@"argument 1 of method \"extent:\" must be a point with no negative coordinate");
    NSPoint pointValue = [self pointValue];
    return NSMakeRect(pointValue.x,pointValue.y,operand.x,operand.y);
  }  
}

- (CGFloat)height
{
  if (strcmp([self objCType],@encode(NSSize)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"height\" sent to a number");
    else
      FSExecError(@"message \"height\" sent to an NSValue that does not contain an NSSize");
  }
  else return [self sizeValue].height;
}

- (NSUInteger)length
{
  if (strcmp([self objCType],@encode(NSRange)) != 0) 
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"length\" sent to a number");
    else
      FSExecError(@"message \"length\" sent to an NSValue that does not contain an NSRange");
  }
  else return [self rangeValue].length;
}

- (NSUInteger)location
{
  if (strcmp([self objCType],@encode(NSRange)) != 0) 
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"location\" sent to a number");
    else
      FSExecError(@"message \"location\" sent to an NSValue that does not contain an NSRange");
  }
  else return [self rangeValue].location;
}

- (NSPoint)origin
{
  if (strcmp([self objCType],@encode(NSRect)) != 0) 
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"origin\" sent to a number");
    else
      FSExecError(@"message \"origin\" sent to an NSValue that does not contain an NSRect");
  }
  else return [self rectValue].origin;
}

- (FSBoolean *)operator_equal:(id)operand
{
  return ([self isEqual:operand] ? fsTrue : fsFalse);
}    

- (FSBoolean *)operator_tilde_equal:(id)operand  
{
  return (![self isEqual:operand] ? fsTrue : fsFalse);
}

- (NSString *)printString
{
  const char *objCType = [self objCType];
  
  if (strcmp(objCType,@encode(NSPoint)) == 0)
  {
    NSPoint pointValue = [self pointValue];
    BOOL yIsNegativeZero = [[[FSNumber numberWithDouble:pointValue.y] printString] isEqualToString:@"-0"];
    if (pointValue.y >= 0 && ! yIsNegativeZero) 
      return [NSString stringWithFormat:@"(%@<>%@)",[FSNumber numberWithDouble:pointValue.x],[FSNumber numberWithDouble:pointValue.y]];
    else                                        
      return [NSString stringWithFormat:@"(%@ <> %@)",[FSNumber numberWithDouble:pointValue.x],[FSNumber numberWithDouble:pointValue.y]];
  }
  else if (strcmp(objCType,@encode(NSRange)) == 0)
  { 
    NSRange rangeValue = [self rangeValue];
    return [NSString stringWithFormat:@"(Range location = %lu length = %lu)",(unsigned long)(rangeValue.location),(unsigned long)(rangeValue.length)];
  }
  else if (strcmp(objCType,@encode(NSRect)) == 0)
  { 
    NSRect rectValue = [self rectValue];
    CGFloat originX = rectValue.origin.x;
    CGFloat originY = rectValue.origin.y;
    CGFloat width = rectValue.size.width;
    CGFloat height = rectValue.size.height;
    BOOL originYIsNegativeZero = [[[FSNumber numberWithDouble:originY] printString] isEqualToString:@"-0"];
    BOOL heightIsNegativeZero  = [[[FSNumber numberWithDouble:height]  printString] isEqualToString:@"-0"];
    NSString *formatString; 
    
    if      (originY >= 0 && !originYIsNegativeZero  && height >= 0 && !heightIsNegativeZero) formatString = @"(%@<>%@ extent:%@<>%@)";
    else if ((originY <  0 || originYIsNegativeZero) && height >= 0 && !heightIsNegativeZero) formatString = @"(%@ <> %@ extent:%@<>%@)";
    else if (originY >= 0 && !originYIsNegativeZero && (height < 0 || heightIsNegativeZero))  formatString = @"(%@<>%@ extent:%@ <> %@)";   
    else                                                                                      formatString = @"(%@ <> %@ extent:%@ <> %@)"; 
    
    return [NSString stringWithFormat:formatString, [FSNumber numberWithDouble:originX], [FSNumber numberWithDouble:originY], [FSNumber numberWithDouble:width], [FSNumber numberWithDouble:height]];
  }
  else if (strcmp(objCType,@encode(NSSize)) == 0)
  { 
    NSSize sizeValue = [self sizeValue];
    return [NSString stringWithFormat:@"(Size width = %@ height = %@)", [FSNumber numberWithDouble:sizeValue.width], [FSNumber numberWithDouble:sizeValue.height]];
  }
  
  return [super printString]; 
}

/*- (NSSize)size
{
  if (strcmp([self objCType],@encode(NSRect)) != 0) FSExecError(@"Receiver of message \"size\" must be an NSValue containing an NSRect");
  return [self rectValue].size;
}*/

- (CGFloat)width
{
  if (strcmp([self objCType],@encode(NSSize)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"width\" sent to a number");
    else
      FSExecError(@"message \"width\" sent to an NSValue that does not contain an NSSize");
  }
  else return [self sizeValue].width;
}

- (CGFloat)x 
{
  if (strcmp([self objCType],@encode(NSPoint)) != 0)   
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"x\" sent to a number");
    else
      FSExecError(@"message \"x\" sent to an NSValue that does not contain an NSPoint");
  }
  else return [self pointValue].x;
}

- (CGFloat)y 
{
  if (strcmp([self objCType],@encode(NSPoint)) != 0) 
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"y\" sent to a number");
    else
      FSExecError(@"message \"y\" sent to an NSValue that does not contain an NSPoint");
  }
  else return [self pointValue].y;
}


- (CGFloat)top
{
  if (strcmp([self objCType],@encode(NSEdgeInsets)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"top\" sent to a number");
    else
      FSExecError(@"message \"top\" sent to an NSValue that does not contain an NSEdgeInsets");
  }
  else return [self edgeInsetsValue].top;
}

- (CGFloat)left
{
  if (strcmp([self objCType],@encode(NSEdgeInsets)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"left\" sent to a number");
    else
      FSExecError(@"message \"left\" sent to an NSValue that does not contain an NSEdgeInsets");
  }
  else return [self edgeInsetsValue].left;
}
- (CGFloat)bottom
{
  if (strcmp([self objCType],@encode(NSEdgeInsets)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"bottom\" sent to a number");
    else
      FSExecError(@"message \"bottom\" sent to an NSValue that does not contain an NSEdgeInsets");
  }
  else return [self edgeInsetsValue].bottom;
}
- (CGFloat)right
{
  if (strcmp([self objCType],@encode(NSEdgeInsets)) != 0)
  {
    if ([self isKindOfClass:[NSNumber class]])
      FSExecError(@"message \"right\" sent to a number");
    else
      FSExecError(@"message \"right\" sent to an NSValue that does not contain an NSEdgeInsets");
  }
  else return [self edgeInsetsValue].right;
}
@end
