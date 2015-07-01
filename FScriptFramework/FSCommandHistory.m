/* StrBuffer.m Copyright (c) 1998-2009 Philippe Mougin.  */
/*   This software is open source. See the license.  */  

#import "FSCommandHistory.h"

@implementation FSCommandHistory 


- (id)init {return [self initWithUIntSize:0];}

- (id)initWithUIntSize:(NSUInteger)maxSize
{
  if ((self = [super init]))
  {
    size = maxSize;
    array = [[NSMutableArray alloc] initWithCapacity:maxSize];
    [array addObject:@""];
    head = 0; queue =0;
    return self;
  }
  return nil;  
}
- (void)dealloc
{
  [array release];
  [super dealloc];
}

-(void)resizeToSize:(NSUInteger)newSize
{
  // TODO
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  if ([coder allowsKeyedCoding]) 
  {
    [coder encodeObject:array forKey:@"array"];
    [coder encodeInteger:head forKey:@"head"];
    [coder encodeInteger:queue forKey:@"queue"];
    [coder encodeInteger:cursor forKey:@"cursor"];
  }
  else {
    [coder encodeObject:array] ;
    [coder encodeValueOfObjCType:@encode(NSInteger) at:&head];
    [coder encodeValueOfObjCType:@encode(NSInteger) at:&queue];
    [coder decodeValueOfObjCType:@encode(NSInteger) at:&cursor];
    
  }
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ([coder allowsKeyedCoding]) 
  {
    array = [[coder decodeObjectForKey:@"array"] mutableCopy];
    head  = [coder decodeIntegerForKey:@"head"];
    queue = [coder decodeIntegerForKey:@"queue"];
    cursor= [coder decodeIntegerForKey:@"cursor"];
  }
  else
  {
    array = [[coder decodeObject] retain];
    [coder decodeValueOfObjCType:@encode(NSInteger) at:&head];
    [coder decodeValueOfObjCType:@encode(NSInteger) at:&queue];
    [coder decodeValueOfObjCType:@encode(NSInteger) at:&cursor];
  }
  return self;
}

- (id)goToFirst
{
  cursor = head;
  return self;
}

- (id)goToLast
{
  cursor = queue;
  return self;
}

- (id)goToNext
{
  if (size != 0)
  {
    if   (cursor == head) cursor = queue;
    else                  cursor = (cursor+1) % array.count;
  }  
  return self;
}

- (id)goToPrevious
{
  if([array count] != 0)
  {
    if   (cursor == queue)  cursor = head;
    else                    cursor = (cursor - 1 + array.count) % array.count;
  } 
  return self;
}  
  
- (NSString *)getMostRecentlyInsertedStr
{
  return (size != 0) ? [array objectAtIndex:head] : @"";
}

- (NSString *)getStr
{
  return (size != 0) ? [array objectAtIndex:cursor] : @"";
}

- (id)addStr:(NSString *)str 
{ 
  if (size != 0)
  {
    if (head == array.count-1 && array.count < size) { [array addObject:@""]; }
    head = (head+1) % size;
    if (head == queue) queue = (queue+1) % size;
    [array replaceObjectAtIndex:head withObject:str];
    [self goToLast];
  }
  [self save];
  return self;  
}


+(NSString*)_historyPath:(NSError**)errorOut
{
  static NSString *sHistoryPath = nil;
  if (sHistoryPath == nil) {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, YES ) ;
    if ( paths.count ) {
      NSBundle *appBundle = [NSBundle mainBundle];
      NSString *appName = [ appBundle.infoDictionary objectForKey:@"CFBundleExecutable" ];
      NSString *applicationSupportDir = [paths[0] stringByAppendingPathComponent:appName];
      NSFileManager *fileManager = [NSFileManager new];
      if (![fileManager fileExistsAtPath:applicationSupportDir]) {
        NSError *error   = nil ;
        BOOL success = [ fileManager
                        createDirectoryAtPath:applicationSupportDir
                        withIntermediateDirectories:YES
                        attributes:nil
                        error:&error ] ;
        if ( !success ) {
          if ( errorOut ) {
            *errorOut = error ;
          }
          [fileManager release];
          return nil ;
        }
      }
      sHistoryPath = [applicationSupportDir stringByAppendingPathComponent:@"FScriptHistory.dat"];
      [sHistoryPath retain];
    }
  }
  return sHistoryPath;
}

-(void)save
{
  NSString *historyPath = [FSCommandHistory _historyPath:nil];
  if (historyPath) {
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (archiveData.length) {
      [archiveData writeToFile:historyPath atomically:YES];
    }
  }
}

+(FSCommandHistory*)latestHistoryWithSize:(NSUInteger)maxSize
{
  NSString *historyPath = [FSCommandHistory _historyPath:nil];
  FSCommandHistory *history = nil;
  NSFileManager *fileManager = [NSFileManager new];
  if (historyPath && [fileManager fileExistsAtPath:historyPath]) {
    history = [[NSKeyedUnarchiver unarchiveObjectWithFile:historyPath] retain];
    history->size = maxSize;
  }
  [fileManager release];
  return history ?: [[FSCommandHistory alloc] initWithUIntSize:maxSize];
  
  
}
@end
