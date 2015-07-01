/*   FSNSDistantObject.m Copyright (c) 2001-2009 Philippe Mougin.  */
/*   This software is open source. See the license.  */  

#import "FSNSDistantObject.h"
#import "FSVoid.h"
#import "build_config.h"
#import "FSNSStringPrivate.h"
#import "FSBoolean.h"
#import "FSNSString.h"
#import "FScriptFunctions.h"
#import "FSNSNumber.h"
#import "FSNumber.h"
#import "NumberPrivate.h"
#import "ArrayPrivate.h"
#import "FSBooleanPrivate.h"
#import "FSNSObject.h"
#import "FSNSProxy.h"
#import "FSBlock.h"
#import <objc/objc.h>
#import <AppKit/AppKit.h>
#import "FSAssociation.h"

@interface NSObject(FSNSObjectPrivate)

- (id) _operator_equal_remote:(id)operand;
- (id) _operator_tilde_equal_remote:(id)operand;
- (NSString *) _printString_remote;
- (void) _throw_remote;

@end

@interface NSMethodSignature(UndocumentedNSMethodSignature)
+ (NSMethodSignature*) signatureWithObjCTypes:(char *)types;
@end

@implementation NSDistantObject(FSNSDistantObject)

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
  // Partial fix for broken Mac OS X implementation of NSProxy meta-class level.
  // Limitation: this is all hard wired here, and thus will not work for methods added in new categories or new subclasses.
  // Note: signatureWithObjCTypes method is a private and undocumented Cocoa method (Mac OS X 10.1.2)

  if      (selector ==  @selector(proxyWithLocal:connection:))  return [NSMethodSignature signatureWithObjCTypes:"@@:@@"];
  else if (selector ==  @selector(proxyWithTarget:connection:)) return [NSMethodSignature signatureWithObjCTypes:"@@:@@"];
  else return [[NSProxy class] methodSignatureForSelector:selector];
  // A strange bug in GCC3 (beta) makes using "super" seemingly impossible here.
  // We can't use [self superclass] instead because it's buggy too (it returns NSProxy meta class)!
  // So we hard-wire the use of NSProxy.
}

- (NSString *)descriptionLimited:(NSUInteger)nbElem
{
  // fallback to the standard printString method. No implementation yet of string's length limitation for remote objects.
  return [self printString];
}


///////////////////////// USER METHODS /////////////////////

- (id) applyBlock:(FSBlock *)block
{
  return [block value:self];
}

- (id) classOrMetaclass
{
  return [super classOrMetaclass];
}

- (FSArray *) enlist
{
  return [FSArray arrayWithObject:self];
}

- (FSArray *)enlist:(NSNumber *)operand 
{
  FSArray *r;
  
  VERIF_OP_NSNUMBER(@"enlist:")

  if ([operand doubleValue] < 0)
    FSExecError([NSString stringWithFormat:@"argument of method \"enlist:\" must be non-negative"]);
  
  if ([operand doubleValue] > NSUIntegerMax)
    FSExecError([NSString stringWithFormat:@"argument of method \"enlist:\" must be less or equal to %lu",(unsigned long)NSUIntegerMax]);

  if ((r = [[[FSArray alloc] initFilledWith:self count:[operand doubleValue]] autorelease]))
    return r;
  else
    FSExecError(@"not enough memory");  
}

- (FSBoolean *)operator_equal_equal:(id)operand
{
  /*if ([self respondsToSelector:@selector(_operator_equal_equal_remote:)])
  return [(id)self _operator_equal_equal_remote:operand];
  else */
  return (self == operand ? (id)[FSBoolean fsTrue] : (id)[FSBoolean fsFalse]);
}

- (FSAssociation *)operator_hyphen_greater:(id)operand
{
  return [FSAssociation associationWithKey:self value:operand];
}

- (FSBoolean *)operator_tilde_tilde:(id)operand;
{
  /* if ([self respondsToSelector:@selector(_operator_tilde_tilde_remote:)])
  return [(id)self _operator_tilde_tilde_remote:operand];
  else */
  return (self == operand ? (id)[FSBoolean fsFalse] : (id)[FSBoolean fsTrue]);
}

- (NSString *)printString
{ 
  NSString *remoteObjectPrintString;
  
  if ([self respondsToSelector:@selector(_printString_remote)]) 
    remoteObjectPrintString = [(id)self _printString_remote];
  else                                                           
    remoteObjectPrintString = [self description];
  
  if ([self isKindOfClass:[FSVoid class]]) return remoteObjectPrintString;
  return [@"a proxy for " stringByAppendingString:remoteObjectPrintString];
}

- (void)throw
{ 
//******************************************************************************************
// We should do the folowing but a bug (Mac OS X 10.4.4) prevents us to do so (when an
// non-NSException object is thrown in a remote method call, the client waits indefinitely).
//******************************************************************************************
//  if ([self respondsToSelector:@selector(_throw_remote)]) [(id)self _throw_remote];
//  else @throw self;

  @throw self;
}

- (NSConnection *)vend:(NSString *)operand
{
  NSConnection *theConnection;

  VERIF_OP_NSSTRING(@"vend:")

  theConnection = [[NSConnection alloc] init];
  [theConnection setRootObject:self];
  if ([theConnection registerName:operand] == NO) return nil;
  else                                            return theConnection;
}


/* FSNSString, FSNSArray, FSNSNumber support */

/*
- (Block *) asBlock
{
  return [self asBlockOnError:nil];
}

- (Block *) asBlockOnError:(Block *)errorBlock  // untested
{
  if ([self isKindOfClass:[NSString class]])
    return [[NSString stringWithString:(NSString *)self] asBlockOnError:errorBlock];  // get a local copy then send the message
  else
    FSExecError(@"F-Script distributed object support report: the message \"asBlock\" or \"asBlockOnError:\" must be sent to an NSString");  
}

- (NSString *)descriptionLimited:(unsigned)nbElem
{
  return [self printString];
} 

*/

- (NSUInteger) _ul_count  
{
   return [self isKindOfClass:[NSArray class]] ? [(id)self count] : 1;
}

- (id)_ul_objectAtIndex:(NSUInteger)index 
{ 
  return [self isKindOfClass:[NSArray class]] ? [(id)self objectAtIndex:index] : [self self];
}
 
/*+ (id)superclass
{
  return ((struct objc_class {
    struct objc_class *isa;
    struct objc_class *super_class;
  } *)self)->super_class; 
}*/

@end
