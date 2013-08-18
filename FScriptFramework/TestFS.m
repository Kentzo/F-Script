#import "TestFS.h"
#import <Foundation/Foundation.h>
#import "FSArray.h"
#import "FSBlock.h"
#import "FSNSString.h"
#import "FSInterpreterResult.h"
#import <objc/objc-class.h>
#import "FSMiscTools.h"
#import <servers/bootstrap.h>
#import <mach/task_special_ports.h>
#import <mach/mach_init.h>
#import "PointerPrivate.h"
#include <stdbool.h>
#include <malloc/malloc.h>
#import "FSFlight.h"
#import "FSAirplane.h" 
#import "FSPilot.h"
#import "FSConstantsInitialization.h"
#include <unistd.h> 
#import <ExceptionHandling/NSExceptionHandler.h>
#include <stdbool.h>
#import "FScriptMenuItem.h"
#import "FSNumber.h"
#import "FScriptFunctions.h" 
#import "FSPointer.h"
#import "FSGenericPointer.h"
#import "FSGenericPointerPrivate.h"
#import <CoreData/CoreData.h>
#import "KTestManager.h"

#include <ffi/ffi.h>
#include <sys/mman.h>

unsigned char foo(unsigned int, float);

static void foo_closure(ffi_cif*, void*, void**, void*);

int testFFI()
{
  ffi_cif cif;
  ffi_closure *closure;
  ffi_type *arg_types[2];
  ffi_arg result;
  ffi_status status;
  
  // Specify the data type of each argument. Available types are defined
  // in <ffi/ffi.h>.
  arg_types[0] = &ffi_type_uint;
  arg_types[1] = &ffi_type_float;
  
  // Allocate a page to hold the closure with read and write permissions.
  if ((closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0)) == (void*)-1)
  {
    // Check errno and handle the error.
  }
  
  // Prepare the ffi_cif structure.
  if ((status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, &ffi_type_uint8, arg_types)) != FFI_OK)
  {
    // Handle the ffi_status error.
  }
  
  // Prepare the ffi_closure structure.
  if ((status = ffi_prep_closure(closure, &cif, foo_closure, NULL)) != FFI_OK)
  {
    // Handle the ffi_status error.
  }
  
  // Ensure that the closure will execute on all architectures.
  if (mprotect(closure, sizeof(closure), PROT_READ | PROT_EXEC) == -1)
  {
    // Check errno and handle the error.
  }
  
  // The closure is now ready to be executed, and can be saved for later
  // execution if desired.
  
  // Invoke the closure.
  result = ((unsigned char(*)(float, unsigned int))closure)(42, 5);
  
  NSLog(@"result = %@", [NSNumber numberWithUnsignedChar:result]);
  
  // Free the memory associated with the closure.
  if (munmap(closure, sizeof(closure)) == -1)
  {
    // Check errno and handle the error.
  }
  
  return 0;
}

// Invoking the closure transfers control to this function.
static void foo_closure(ffi_cif* cif, void* result, void** args, void* userdata)
{
  // Access the arguments to be sent to foo().
  float arg1 = *(float*)args[0];
  unsigned int arg2 = *(unsigned int*)args[1];
  
  // Call foo() and save its return value.
  unsigned char ret_val = foo(arg1, arg2);
  
  // Copy the returned value into result. Because the return value of foo()
  // is smaller than sizeof(long), typecast it to ffi_arg. Use ffi_sarg
  // instead for signed types.
  *(ffi_arg*)result = (ffi_arg)ret_val;
}

// The closed-over function.
unsigned char foo(unsigned int x, float y)
{
  unsigned char result = x - y;
  return result;
}


@interface NSMethodSignature(UndocumentedNSMethodSignature)
+ (NSMethodSignature*) signatureWithObjCTypes:(char *)types;
@end

@interface FSNumber(NumberExt)
+ numberWithDoubleNoCache:(double)val;
@end 

extern FSNumber *numberWithDouble(double val);

@implementation TestFS : NSObject

@synthesize p1 = p_p1;
@synthesize toto = p_toto;
@synthesize tutu = p_tutu;
//@synthesize zozo = p_zozo;

//@dynamic dynamicProperty;

- dynamicProperty
{
  return @"hello";
}

- testProperty
{
  return self.dynamicProperty;
}


+ (void)testFFI
{
  testFFI();
}

- (fsstruct) zozo { fsstruct r; r.a = 5; r.b = 88; return r;}

+ :(id)arg
{
  return arg;
}

+ testColonSelector
{
  return [self :self];
}

+ (SEL) nullSel {return (SEL)0;}

+ (NSInteger)query:(NSArray *)A :(NSArray *)F :(NSArray *)P
{
  NSInteger result;
  NSString *city;
  FSFlight *flight;
  NSCountedSet *countedSet = [NSCountedSet set];
  NSEnumerator *enumerator = [F objectEnumerator];

  while ((flight = [enumerator nextObject])) 
  {
    [countedSet addObject:[flight arrivalLocation]];
  }
  
  enumerator = [countedSet objectEnumerator];
  result = 0;
  
  while ((city = [enumerator nextObject])) 
  {
    if ([countedSet countForObject:city] < 50) 
      result++;
  }
  return result;
} 

+ (NSArray *)query2:(NSArray *)A :(NSArray *)F :(NSArray *)P
{
  FSAirplane *airplane;
  FSPilot *pilot;
  FSFlight *flight;
  NSMutableArray *result = [NSMutableArray array];
  NSEnumerator *pilotEnumerator = [P objectEnumerator];

  while ((pilot = [pilotEnumerator nextObject]))
  {
    NSEnumerator *airplaneEnumerator = [A objectEnumerator];
    while ((airplane = [airplaneEnumerator nextObject]))
    {
      NSEnumerator *flightEnumerator = [F objectEnumerator];
      while ((flight = [flightEnumerator nextObject]))
      {
        if ([flight airplane] == airplane && [flight pilot] == pilot)
        {
          break;
        }  
      }
      if (!flight) break;
    }
    if (!airplane) [result addObject:pilot];
  }
  return result;
} 


+ (NSUInteger) uintmax
{
  return UINT_MAX;
}

+ (long long) llongmax
{
  return LLONG_MAX;
}

+ (long long) llongmaxMinusOne
{
  return LLONG_MAX-1;
}


+ (void)printIntegerTypeInfo
{
  printIntegerTypeInfo();
}

+ (NSUInteger) booleanSize
{ 
  return sizeof(_Bool);
}

+ (void) testClass:(Class)arg1 with:(NSInteger)arg2
{return;}



- (id) testStr
{
  return @"str";
}


/*- (id) test:(Class) cls
{
  Array *r = [Array array];
  void *iterator = 0;
  struct objc_method_list *mlist;
  NSInteger i = 0;
  while ( mlist = class_nextMethodList( cls, &iterator ) )
  {
    for (i = 0; i < mlist->method_count; i++)
    {
      [r add:[Block blockWithSelector:mlist->method_list[i].method_name]];
    }
  }
  return r;
}*/

-(SEL) test2
{
  return @selector(operator_plus:);
}


+ (void) testvoid { return;}

- (id) testvoid {return [FSNumber numberWithDouble:88];} 

- (FSArray *) test3
{
  
  /*void                    *iterator = 0;
  struct objc_method_list *methods;
  int                     i;
  Class                   cls = [NSArray class];*/
  FSArray *r = [FSArray array]; 

  //while (cls)
  //{
  //  while ( methods = class_nextMethodList( cls, &iterator ) )
  //  {
  /*    methods = class_nextMethodList( cls, &iterator );
      for ( i = 0; i < methods->method_count; i++ ) 
      {
        struct objc_method method     = methods->method_list[ i];
        SEL                selector   = method.method_name;

        [r addObject:[NSString stringWithCString:sel_getName( selector )]];
      }*/
  //  }
    
  //  cls = [cls superclass];
  //}    
  return r;
}

- (BOOL)testNSProxy
{
  return isKindOfClassNSProxy([NSDistantObject class]);
}

+ (BOOL)testx
{
  return [NSDistantObject isKindOfClass:[NSProxy class]];
}

+(Protocol*)proto
{
  return @protocol(NSObject);
}

/*+ boot
{
  NSMutableArray *r = [NSMutableArray array];
  int i;
  
  kern_return_t infoReturn;
  mach_port_t bootstrap_port;
  name_array_t service_names;
  mach_msg_type_number_t service_namesCnt;
  name_array_t server_names;
  mach_msg_type_number_t server_namesCnt;
  bool_array_t service_active;
  mach_msg_type_number_t service_activeCnt;  

  task_get_bootstrap_port(mach_task_self(), &bootstrap_port);
  
  infoReturn = bootstrap_info(bootstrap_port, &service_names, &service_namesCnt, &server_names, &server_namesCnt, &service_active, &service_activeCnt);

  for (i = 0; i < service_namesCnt; i++)
  {
    [r addObject:[NSString stringWithCString:service_names[i] length:128]];
  }
  [r addObject:[NSString stringWithFormat:@"Number of services = %d", service_namesCnt]];
  return r;
}*/

+ (BOOL) tt
{
  return [NSEvent respondsToSelector:@selector(keyEventWithType:location:modifierFlags:timestamp:windowNumber:context:characters:charactersIgnoringModifier:isARepeat:keyCode:)];
  //return [NSEvent respondsToSelector:@selector(mouseEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:clickCount:pressure:)];
}

+ (NSEvent *) tt2
{
 // return [NSEvent keyEventWithType:4 location:NSMakePoint(40,40) modifierFlags:0 timestamp:40 windowNumber:1 context:nil characters:@"r" charactersIgnoringModifier:@"r" isARepeat:NO keyCode:67];
  return nil;
}

static NSInteger p = 362; 

+ (NSInteger *)pointer
{ NSLog(@"TestFS return %p", &p); return &p;}

+ (NSInteger *)pointerWith:object with:(NSInteger)i
{ NSLog(@"object received: %@, int received:%ld . TestFS return %p",object, (long)i, &p); return &p;}

+ (void) setPValue:(NSInteger)new
{ p = new; }

+ (NSInteger)pValue {return p;}

+ (void)setPointer:(NSInteger *)p
{
  NSLog(@"setPointer: received pointer to %p", p);
  NSLog(@"%ld", (long)*p);
}

+ (FSPointer *)fsPointer 
{
  return [[[FSGenericPointer alloc] initWithCPointer:&p freeWhenDone:NO type:@encode(__typeof__(p))] autorelease];
}

+ (NSInteger) sized
{
  return sizeof(double);
}



/*+ bench:(Array)*a
{
    
}*/

- (void)forwardInvocation:(NSInvocation *)invocation
{
  NSLog(@"In forwardInvocation:, invocation = %@", invocation);
  [invocation setSelector:@selector(fff)];
  [invocation invokeWithTarget:self];
}

- (id)fff
{
  NSLog(@"In fff");
  return self;
}

/*- (id)testForward
{
  return [self edr];
}*/

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  if (aSelector == @selector(edr)) return [NSMethodSignature signatureWithObjCTypes:"@@:"];
  else return [super methodSignatureForSelector:aSelector];
}

- (BOOL) respondsToSelector:(SEL)aSelector
{
  if (aSelector == @selector(edr)) return YES;
  else return [super respondsToSelector:aSelector];
}

- (NSDictionary *) constants
{
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  FSConstantsInitialization(d);
  return d;
}


+(SEL)mySel
{
  SEL selector;
  NSInteger i;
  
  selector = NSSelectorFromString(@"initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bytesPerRow:bitsPerPixel:");
  i = 8;
  return selector;
}

+(SEL)mySel2
{
  SEL selector;
  NSInteger i;
  
  selector = NSSelectorFromString(@"initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bytesPerRow:bitsPerPixel:");
  i = 8;
  return selector;
}

/*+ (void) error
{
  int *p = 0;
  printf("handling = %d --- hanging = %d",[[NSExceptionHandler defaultExceptionHandler] exceptionHandlingMask],[[NSExceptionHandler defaultExceptionHandler] exceptionHangingMask]);
  fflush(stdout);
  int a = *p;
}*/

+(NSUInteger)mask
{
  return [[NSExceptionHandler defaultExceptionHandler] exceptionHangingMask];
}

+(double)ld
{
  long long ll1 = 2;
  //unsigned long long ll2 = 1;
  //double r = (long long)(ll2-ll1);
  return sizeof(ll1);
}

+(void) passll:(long long)ll
{
  NSLog(@"%@", [NSNumber numberWithLongLong:ll]);
}

+(void) passull:(unsigned long long)ull
{
  NSLog(@"%@", [NSNumber numberWithUnsignedLongLong:ull]); 
}

+(NSNumber *)ullong_max
{
  return [NSNumber numberWithUnsignedLongLong:ULLONG_MAX];
}


+ (void) FSExecError
{
  FSExecError(@"error test");
}

+(NSSize) size
{
  return NSMakeSize(-3,-10);
}

+ (_Bool) bbbt
{return true;}

+ (_Bool) bbbf
{return false;}

+(_Bool)bbb:(_Bool)b
{ return b;}

+(_Bool)bbbn:(_Bool)b
{ return !b;}

+ (unsigned char)returnUnsignedChar 
{ 
  unsigned char r = 8; 
  return r; 
}

+ ( char)returnChar 
{ 
  char r = 8; 
  return r; 
}


+ (char *) BOOLe
{return @encode(BOOL);}

static NSPoint point;

+ (NSPoint *) pointPointer {point.x = 10; point.y = 20; return &point;}

+ (NSInteger) BOOLs
{return sizeof(BOOL);}

+ (void) findPathToFileInLibraryWithinUserDomain
/*" Retuns the path to the first occurrence of fileName in a Library
directory within the User domain. "*/
{
  NSString      *result = nil;		// the returned path
  NSString      *candidate;        	// candidate paths
  NSArray       *pathArray;        	// array of standard locations
  NSEnumerator  *pathEnumerator;	// used to enumerate pathArray

  pathArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  pathEnumerator = [pathArray objectEnumerator];

  while(nil == result && (nil != (candidate = [pathEnumerator nextObject])))
  {
    NSLog(@"%@", candidate);
  }
}

+(void) testLock
{
  NSLock *lock = [[NSLock alloc] init];
  NSInteger i;
  for (i = 0; i < 700000; i++)
  {
    [lock lock];
    [lock unlock];
  }
}

+(void) testLock2
{
  NSInteger i;
  for (i = 0; i < 700000; i++)
  {
    [FSNumber numberWithDouble:3.0];
  }
}

+(void) testLock3
{
  NSInteger i;
  for (i = 0; i < 700000; i++)
  {
    numberWithDouble(3.0);
  }
}

+(void) testLock4
{
  NSInteger i;
  for (i = 0; i < 700000; i++)
  {
    [FSNumber numberWithDoubleNoCache:3.0];
  }
}

+(void) threadTest:(FSBlock *)block
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [block value];
  [pool release];
}

+(void)addMenu
{
  [[NSApp mainMenu] addItem: [[[FScriptMenuItem alloc] init] autorelease]];
}

/*
-(id)idRaise
{
  [NSException raise:@"Exception Test" format:@"This is an exception for test purpose"];
}

-(double)doubleRaise
{
  [NSException raise:@"Exception Test" format:@"This is an exception for test purpose"];
}

-(NSSize)sizeRaise
{
  [NSException raise:@"Exception Test" format:@"This is an exception for test purpose"];
}

-(NSRect)rectRaise
{
  [NSException raise:@"Exception Test" format:@"This is an exception for test purpose"];
}
*/



+ managed
{
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
  NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] init];
  
  NSEntityDescription *employeeEntity = [[[NSEntityDescription alloc] init] autorelease];
  [employeeEntity setName:@"employee"];
  [employeeEntity setManagedObjectClassName:@"NSManagedObject"]; 
    
  NSEntityDescription *departmentEntity = [[[NSEntityDescription alloc] init] autorelease];
  [departmentEntity setName:@"department"];
  [departmentEntity setManagedObjectClassName:@"Department"];
  
  NSAttributeDescription *nameAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [nameAttribute setName:@"name"];
  [nameAttribute setAttributeType:NSStringAttributeType];
  
  NSAttributeDescription *budgetAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [budgetAttribute setName:@"budget"];
  [budgetAttribute setAttributeType:NSInteger32AttributeType];
  
  NSRelationshipDescription *employeesRelationship = [[[NSRelationshipDescription alloc] init] autorelease];
  [employeesRelationship setName:@"employees"];
  [employeesRelationship setDestinationEntity:employeeEntity];
  [employeesRelationship setMinCount:0];
  [employeesRelationship setMaxCount:999];
 
  NSAttributeDescription *firstNameAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [firstNameAttribute setName:@"firstName"];
  [firstNameAttribute setAttributeType:NSStringAttributeType];
  [firstNameAttribute setDefaultValue:@""];
  
  NSAttributeDescription *lastNameAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [lastNameAttribute setName:@"lastName"];
  [lastNameAttribute setAttributeType:NSStringAttributeType];
  [lastNameAttribute setDefaultValue:@""];
  
  NSAttributeDescription *salaryAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [salaryAttribute setName:@"salary"];
  [salaryAttribute setAttributeType:NSInteger32AttributeType];
  
  NSAttributeDescription *blongaAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [blongaAttribute setName:@"Blonga"];
  [blongaAttribute setAttributeType:NSInteger32AttributeType];

    
  NSAttributeDescription *phoneAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [phoneAttribute setName:@"phone"];
  [phoneAttribute setAttributeType:NSStringAttributeType];
  
  NSAttributeDescription *emailAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [emailAttribute setName:@"email"];
  [emailAttribute setAttributeType:NSStringAttributeType];
  
  NSAttributeDescription *addressAttribute = [[[NSAttributeDescription alloc] init] autorelease];
  [addressAttribute setName:@"address"];
  [addressAttribute setAttributeType:NSStringAttributeType];


  NSRelationshipDescription *managerRelationship = [[[NSRelationshipDescription alloc] init] autorelease];
  [managerRelationship setName:@"manager"];
  [managerRelationship setDestinationEntity:employeeEntity];
  [managerRelationship setMinCount:0];
  [managerRelationship setMaxCount:1];
  
  NSRelationshipDescription *directReportsRelationship = [[[NSRelationshipDescription alloc] init] autorelease];
  [directReportsRelationship setName:@"directReports"];
  [directReportsRelationship setDestinationEntity:employeeEntity];
  [directReportsRelationship setMinCount:0];
  [directReportsRelationship setMaxCount:99];   
  
  NSRelationshipDescription *departmentRelationship = [[[NSRelationshipDescription alloc] init] autorelease];
  [departmentRelationship setName:@"department"];
  [departmentRelationship setDestinationEntity:departmentEntity];
  [departmentRelationship setMinCount:0];
  [departmentRelationship setMaxCount:1];

  [managerRelationship setInverseRelationship:directReportsRelationship];
  [directReportsRelationship setInverseRelationship:managerRelationship];
  
  [departmentRelationship setInverseRelationship:employeesRelationship];
  [employeesRelationship setInverseRelationship:departmentRelationship];

  [employeeEntity setProperties:[NSArray arrayWithObjects:firstNameAttribute, lastNameAttribute, salaryAttribute, phoneAttribute, emailAttribute, addressAttribute, managerRelationship, directReportsRelationship, departmentRelationship, blongaAttribute,nil]];
  [departmentEntity setProperties:[NSArray arrayWithObjects:nameAttribute, budgetAttribute, employeesRelationship, nil]];

  NSArray *entities = [NSArray arrayWithObjects:departmentEntity, employeeEntity, nil];
  
  [objectModel setEntities:entities];

  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
  
  [context setPersistentStoreCoordinator:coordinator];

  NSManagedObject *department1 = [[[NSManagedObject alloc] initWithEntity:departmentEntity insertIntoManagedObjectContext:context] autorelease];
  [department1 setValue:@"R&D" forKey:@"name"]; 
  [department1 setValue:[NSNumber numberWithInt:450000] forKey:@"budget"]; 

  NSManagedObject *department2 = [[[NSManagedObject alloc] initWithEntity:departmentEntity insertIntoManagedObjectContext:context] autorelease];
  [department2 setValue:@"Sales" forKey:@"name"]; 
  [department2 setValue:[NSNumber numberWithInt:575000] forKey:@"budget"]; 

  NSManagedObject *department3 = [[[NSManagedObject alloc] initWithEntity:departmentEntity insertIntoManagedObjectContext:context] autorelease];
  [department3 setValue:@"Support" forKey:@"name"]; 
  [department3 setValue:[NSNumber numberWithInt:10000] forKey:@"budget"]; 

  NSManagedObject *department4 = [[[NSManagedObject alloc] initWithEntity:departmentEntity insertIntoManagedObjectContext:context] autorelease];
  [department4 setValue:@"Marketing" forKey:@"name"]; 
  [department4 setValue:[NSNumber numberWithInt:110000] forKey:@"budget"]; 
   
  NSManagedObject *employee1 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee1 setValue:@"John" forKey:@"firstName"];
  [employee1 setValue:@"Smith" forKey:@"lastName"];
  [employee1 setValue:[NSNumber numberWithInt:3000] forKey:@"salary"];
  [employee1 setValue:@"jsmith@supercool.com" forKey:@"email"];
  [employee1 setValue:@"08 65 424" forKey:@"phone"];
  [employee1 setValue:@"9 Lupo Place, 74986 Coolville" forKey:@"address"];

  NSManagedObject *employee2 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee2 setValue:@"Jean-Louis" forKey:@"firstName"];
  [employee2 setValue:@"Langlois" forKey:@"lastName"];
  [employee2 setValue:[NSNumber numberWithInt:3700] forKey:@"salary"];
  [employee2 setValue:@"jllanglois@supercool.com" forKey:@"email"];
  [employee2 setValue:@"04 56 896" forKey:@"phone"];
  [employee2 setValue:@"7 Bleker Street, 74986 Coolville" forKey:@"address"];

  NSManagedObject *employee3 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee3 setValue:@"Henri" forKey:@"firstName"];
  [employee3 setValue:@"Carter" forKey:@"lastName"];
  [employee3 setValue:[NSNumber numberWithInt:3800] forKey:@"salary"];
  [employee3 setValue:@"hcarter@supercool.com" forKey:@"email"];
  [employee3 setValue:@"04 55 654" forKey:@"phone"];
  [employee3 setValue:@"850 Bleker Street, 74986 Coolville" forKey:@"address"];
  
  NSManagedObject *employee4 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee4 setValue:@"Fred" forKey:@"firstName"];
  [employee4 setValue:@"Fonda" forKey:@"lastName"];
  [employee4 setValue:[NSNumber numberWithInt:4300] forKey:@"salary"];
  [employee4 setValue:@"ffonda@supercool.com" forKey:@"email"];
  [employee4 setValue:@"02 76 654" forKey:@"phone"];
  [employee4 setValue:@"23 Roma Street, 40538 Fairyville" forKey:@"address"];
  
  NSManagedObject *employee5 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee5 setValue:@"Phil" forKey:@"firstName"];
  [employee5 setValue:@"Berry" forKey:@"lastName"];
  [employee5 setValue:[NSNumber numberWithInt:2200] forKey:@"salary"];
  [employee5 setValue:@"pberry@supercool-uk.com" forKey:@"email"];
  [employee5 setValue:@"04 98 652" forKey:@"phone"];
  [employee5 setValue:@"6 Panda Street, 40538 Fairyville" forKey:@"address"];
  
  NSManagedObject *employee6 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee6 setValue:@"Eric" forKey:@"firstName"];
  [employee6 setValue:@"Bill" forKey:@"lastName"];
  [employee6 setValue:[NSNumber numberWithInt:4000] forKey:@"salary"];
  [employee6 setValue:@"ebill@supercool-uk.com" forKey:@"email"];
  [employee6 setValue:@"04 56 896" forKey:@"phone"];
  [employee6 setValue:@"67 Cool Street, 74986 Coolville" forKey:@"address"];

  NSManagedObject *employee7 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee7 setValue:@"Hannah" forKey:@"firstName"];
  [employee7 setValue:@"Mig" forKey:@"lastName"];
  [employee7 setValue:[NSNumber numberWithInt:3750] forKey:@"salary"];
  [employee7 setValue:@"hmig@supercool.com" forKey:@"email"];
  [employee7 setValue:@"02 76 109" forKey:@"phone"];
  [employee7 setValue:@"34 Super Street, 40538 Fairyville" forKey:@"address"];

  NSManagedObject *employee8 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee8 setValue:@"Suzan" forKey:@"firstName"];
  [employee8 setValue:@"Mina" forKey:@"lastName"];
  [employee8 setValue:[NSNumber numberWithInt:3550] forKey:@"salary"];
  [employee8 setValue:@"webmaster@supercool.com" forKey:@"email"];
  [employee8 setValue:@"05 45 123" forKey:@"phone"];
  [employee8 setValue:@"70 Quality Street, 74986 Coolville" forKey:@"address"];
  
  NSManagedObject *employee9 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee9 setValue:@"Irene" forKey:@"firstName"];
  [employee9 setValue:@"French" forKey:@"lastName"];
  [employee9 setValue:[NSNumber numberWithInt:3200] forKey:@"salary"];
  [employee9 setValue:@"ifrench@supercool.com" forKey:@"email"];
  [employee9 setValue:@"04 56 875" forKey:@"phone"];
  [employee9 setValue:@"953 Long Street, 40538 Fairyville" forKey:@"address"];

  NSManagedObject *employee10 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee10 setValue:@"Alan" forKey:@"firstName"];
  [employee10 setValue:@"Peer" forKey:@"lastName"];
  [employee10 setValue:[NSNumber numberWithInt:3000] forKey:@"salary"];
  [employee10 setValue:@"apeer@supercool.com" forKey:@"email"];
  [employee10 setValue:@"04 56 100" forKey:@"phone"];
  [employee10 setValue:@"1 Short Street, 40538 Fairyville" forKey:@"address"];
  
  NSManagedObject *employee11 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee11 setValue:@"Daniel" forKey:@"firstName"];
  [employee11 setValue:@"Wylde" forKey:@"lastName"];
  [employee11 setValue:[NSNumber numberWithInt:3900] forKey:@"salary"];
  [employee11 setValue:@"dwylde@supercool.com" forKey:@"email"];
  [employee11 setValue:@"04 34 982" forKey:@"phone"];
  [employee11 setValue:@"76 Cocoa Place, 74986 Coolville" forKey:@"address"];
  
  NSManagedObject *employee12 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee12 setValue:@"Brett" forKey:@"firstName"];
  [employee12 setValue:@"Sinclair" forKey:@"lastName"];
  [employee12 setValue:[NSNumber numberWithInt:3000] forKey:@"salary"];
  [employee12 setValue:@"bsinclair@supercool.com" forKey:@"email"];
  [employee12 setValue:@"04 51 221" forKey:@"phone"];
  [employee12 setValue:@"211 Salon Street, 40538 Fairyville" forKey:@"address"];

  NSManagedObject *employee13 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee13 setValue:@"Britany" forKey:@"firstName"];
  [employee13 setValue:@"Holder" forKey:@"lastName"];
  [employee13 setValue:[NSNumber numberWithInt:3400] forKey:@"salary"];
  [employee13 setValue:@"bholder@supercool.com" forKey:@"email"];
  [employee13 setValue:@"01 23 432" forKey:@"phone"];
  [employee13 setValue:@"21 Life Street, 03242 Aloa" forKey:@"address"];
  
  NSManagedObject *employee14 = [[[NSManagedObject alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:context] autorelease];
  [employee14 setValue:@"Angela" forKey:@"firstName"];
  [employee14 setValue:@"Lucidi" forKey:@"lastName"];
  [employee14 setValue:[NSNumber numberWithInt:3800] forKey:@"salary"];
  [employee14 setValue:@"alucidi@supercool.com" forKey:@"email"];
  [employee14 setValue:@"04 87 336" forKey:@"phone"];
  [employee14 setValue:@"9 Rich Street, 03242 Aloa" forKey:@"address"];
   
  [employee1 setValue:employee2 forKey:@"manager"];
  [employee1 setValue:department1 forKey:@"department"];

  [employee2 setValue:department1 forKey:@"department"];

  [employee3 setValue:employee2 forKey:@"manager"];
  [employee3 setValue:department1 forKey:@"department"];
  
  [employee4 setValue:employee2 forKey:@"manager"];
  [employee4 setValue:department1 forKey:@"department"];

  [employee5 setValue:employee2 forKey:@"manager"];
  [employee5 setValue:department1 forKey:@"department"];
  
  [employee6 setValue:department2 forKey:@"department"];
  
  [employee7 setValue:employee6 forKey:@"manager"];
  [employee7 setValue:department2 forKey:@"department"];

  [employee8 setValue:employee6 forKey:@"manager"];
  [employee8 setValue:department2 forKey:@"department"];

  [employee9 setValue:employee6 forKey:@"manager"];
  [employee9 setValue:department3 forKey:@"department"];
  
  [employee10 setValue:department4 forKey:@"department"];

  [employee11 setValue:employee10 forKey:@"manager"];
  [employee11 setValue:department4 forKey:@"department"];

  [employee12 setValue:employee11 forKey:@"manager"];
  [employee12 setValue:department4 forKey:@"department"];
  
  [employee13 setValue:employee2 forKey:@"manager"];
  [employee13 setValue:department1 forKey:@"department"];

  [employee14 setValue:employee11 forKey:@"manager"];
  [employee14 setValue:department4 forKey:@"department"];

  return employee1;  
}


+(id)aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
{
  return nil;
}

+classFromString:(NSString *)string
{
  return NSStringFromClass(NSClassFromString(string));
}

+stringFromClass:(Class)aClass
{
  return @"haha";
}

+ (void) method1:(NSNumber **)p
{
  // Replace the NSNumber referenced by p by a new NSNumber 
  // with a value that is the double of the original one.

  *p = [NSNumber numberWithDouble:[*p doubleValue] * 2];
}


+ (id)november2005
{
  return @"november 2005";
}

+ stringSelect:(NSArray *) strings
{
  NSString *aString;
  NSMutableArray *result = [NSMutableArray array];

  NSEnumerator *stringEnumerator = [strings objectEnumerator];
  while ((aString = [stringEnumerator nextObject]))
  {
      if ([aString length] < 10) 
        [result addObject:aString];  
  }
  return result;
}

+ (id)testincr
{
  NSInteger x,y;
  x = 10;
  y = 2 * (++x);
  return [NSNumber numberWithInt:y];
}

+ (void) throwObject:(id)object
{
  @throw object;
}

+ (void) throw
{
  @throw @"ZZZZ";
}

 
+(NSInteger)throwNil
{
  id object = @"yaa";
  @try
  {
    NSLog(@"WillThrow");
    @throw object;
    NSLog(@"after throw !!!!");
  }
  @catch (id exception)
  {
    NSLog(@"Catch");
    return 1;
  }
  
  NSLog(@"End");
  return 22;
}

+(NSInteger)finally1
{
  @try
  {
    @throw @"hello";
  }
  @finally
  {
    NSLog(@"finally");
  }
  return 88;
}

+(NSInteger)finally2
{
  NSInteger i;
  @try
  {
    i = 6+4;
  }
  @finally
  {
    NSLog(@"finally");
  }
  return 88;
}
 
+ (void)exec
{
  FSBlock *myBlock = [@"[:a :b| a/b]" asBlock];
  NSArray *arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:0], nil];
  FSInterpreterResult *interpreterResult = [myBlock executeWithArguments:arguments];
  
  if ([interpreterResult isOK])
    NSLog(@"Execution OK. Result = %@", [interpreterResult result]);
  else
    NSLog(@"%@", [interpreterResult errorMessage]);
}

- (void)finalize 
{
  NSLog(@"Finalizing a TestFS");
  [super finalize];
}

+ (void *)tst
{
  id *p = NSAllocateCollectable(sizeof(id), NSScannedOption);
  *p = [[TestFS alloc] init];
  return p;
}

+ (id *)tsto
{
  id *p = NSAllocateCollectable(sizeof(id), NSScannedOption);
  *p = [[TestFS alloc] init];
  return p;
}

+ (void)testForIn
{
  FSArray *a = [[NSNumber numberWithDouble:40] iota];
  [a insertObject:nil atIndex:30];
    
  for (id e in a)
  {
    NSLog(@"%@", printString(e));
  }
}  

+ (size_t)malloc_size:(char *)p offset:(int)offset
{
  return malloc_size(p+offset);
}


+ (size_t)malloc_size:(void *)p
{
  return malloc_size(p);
}

+ (size_t)malloc_size_err:(long)p
{
  return malloc_size((void *)p);
}

struct s_unsupported {int i;};

+ (struct s_unsupported) unsupportedType: (struct s_unsupported)arg
{
  return (struct s_unsupported) {89};
}

static int toto = 23;

+ (int *)totoPtr
{
  return &toto;
}

+(NSNumber *)testMix
{
  NSArray *windows = [[NSApplication sharedApplication] windows];
  NSNumber *count = [[@"[ :w | w := w at:w isDocumentEdited. (w at:w title sort) reverse orderFront:nil; count]" asBlock] value:windows];
  return count;
}

+ (float)giveBackFloat:(float)f
{
  return f;
}

void logFloat(int dummy, ...)
{
  va_list pa;
  float f;
  
  va_start(pa, dummy);
  
  f = va_arg(pa, double);
  
  NSLog(@"%@", [NSNumber numberWithFloat:f]);
  
  va_end(pa);
}

+ (void)logFloat
{
  logFloat(12, (float)78.0);
}

+ encodeLong
{
  return [NSString stringWithUTF8String:@encode(long)];
}


+ encodeLongLong
{
  return [NSString stringWithUTF8String:@encode(long long)];
}

+ testffi
{
  KTestManager *t = [[KTestManager alloc] init];
  
  NSInteger        returnValue;
  void             *argumentsValuesPtrs[3];
  ffi_type         *argumentsTypes[3];
  ffi_type         *returnType = &ffi_type_sint64;
  ffi_cif          *cif;
  ffi_status        status;
  
  double arg = 23;
  SEL selector = @selector(testForward1Imp:);
    
  argumentsValuesPtrs[0] = &t;
  argumentsValuesPtrs[1] = &selector;
  argumentsValuesPtrs[2] = &arg;
      
  argumentsTypes[0] = &ffi_type_pointer;
  argumentsTypes[1] = &ffi_type_pointer; // This code assume that SEL is a pointer type
  argumentsTypes[2] = &ffi_type_double;
  
  // Prepare the ffi_cif structure.
  cif = malloc(sizeof(ffi_cif));
  
  if ((status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, 3, returnType, argumentsTypes)) != FFI_OK)
  {
    free(cif);
    FSExecError(@"F-Script internal error: can't prepare the ffi_cif structure for ffi_call");
  }
  
  // Invoke the method
  
  IMP imp = [t methodForSelector:selector];

  //IMP imp = class_getMethodImplementation(object_getClass(t), @selector(testForward1:));
  
  ffi_call(cif, FFI_FN(imp), &returnValue, argumentsValuesPtrs);
  
  free (cif); 
  
  return [NSNumber numberWithInteger:returnValue];
}

+ (CGAffineTransform)CGAffineTransform
{
  return CGAffineTransformMake(12, 100, 13, 101, 3, 4);
}

+ (CGAffineTransform)CGAffineTransform:(CGAffineTransform)cgat
{
  return cgat;
}

+ encodeCGAffineTransform
{
  return [NSString stringWithUTF8String:@encode(CGAffineTransform)];
}

+ (int)dereferenceIntPointer:(int*)p
{
  return *p;
}


+ (BOOL)tollFreeTest
{
  return [NSNumber numberWithBool:NO] == (id)kCFBooleanFalse;
}

+ (NSInteger)iii
{
  return 46;
}

+ rangeEncode
{
  	// calculate the sizes of C-Primitives
	int i = 1;
	NSLog(@"Primitive sizes:");
	NSLog(@"%d The size of a char is: %lu.", i++, sizeof(char));
	NSLog(@"%d The size of short is: %lu.", i++, sizeof(short));
	NSLog(@"%d The size of int is: %lu.",  i++, sizeof(int));
	NSLog(@"%d The size of long is: %lu.",  i++, sizeof(long));
	NSLog(@"%d The size of long long is: %lu.",  i++, sizeof(long long));
	NSLog(@"%d The size of a unsigned char is: %lu.",  i++, sizeof(unsigned char));
	NSLog(@"%d The size of unsigned short is: %lu.",  i++, sizeof(unsigned short));
	NSLog(@"%d The size of unsigned int is: %lu.",  i++, sizeof(unsigned int));
	NSLog(@"%d The size of unsigned long is: %lu.",  i++, sizeof(unsigned long));
	NSLog(@"%d The size of unsigned long long is: %lu.",  i++, sizeof(unsigned long long));
	NSLog(@"%d The size of a float is: %lu.",  i++, sizeof(float));
	NSLog(@"%d The size of a double is %lu.",  i++, sizeof(double));

  return [NSString stringWithUTF8String:@encode(NSRange)];
}


/*
+ block
{
  return ^ id (){return @"hello";};
}
*/

@end

@implementation TestFSSub

@end


